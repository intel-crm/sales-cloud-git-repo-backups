/*******************************************************************************************************************************************************************************************************
* Class Name  : PMP_NavigationBarAPIDetails
* Description : API that gives the navigation bar button details 
* Version     : 1.0 
* Created Date: 07-Oct-2022
* Modification Log :
* Created By  : Onyx Team (Infosys)
********************************************************************************************************************************************************************************************************/


@RestResource(urlMapping='/v1.0/marketplaceNavBarDetails')
global without sharing class PMP_NavigationBarAPIDetails {
    
    //method returns a json with navigation bar button visibility details.
    @HttpPost
    global static NavBarAPIResponse getNavBarDetails(String emailId){
        Boolean isMarketplaceUser = false; // check if the user is MP Partner user
        Boolean showManageOfferings = false; // to store manage offerings button visibility
        Boolean showManageLeads = false; // to store manage leads button visibility
        Boolean showDashboard = false; // to store view dashboard button visibility
        Boolean showManageSolutions= false; // to store manage offerings button visibility
        Boolean showManageStorefront = false; // to store manage storefront button visibility
        Boolean showManagePartners = false; // to store manage partners button visibility
        //IPA 2.0 TWC729-7887	
       // Boolean isBasicAccess = false; 
       //Boolean isEnhanced = false;
        map<String,NavBarButtonAttributes> navigationBarButtons= new map<String,NavBarButtonAttributes>();
        NavBarButtonAttributes navBarDetails= new NavBarButtonAttributes();
        NavBarAPIResponse jsonResponse= new NavBarAPIResponse();
        
        
        try{  
            If(emailId == Null){
                jsonResponse.message='Invalid EmailId';
                return jsonResponse;
            }
            User usr = fetchUser(emailId); // fetch user information for the given email.
            if (usr==null){
                jsonResponse.message='User does not exist in the system';
                return jsonResponse;
            }
            
            isMarketplaceUser = isMarketplaceUser(usr) ? true:false; //check if user is MP Partner user
            List<String> listOfPermissions = Label.PMP_All_Custom_Permissions.split(';');
            List<String> customPermissions= hasPermission(listOfPermissions, usr);
            boolean is_PMP_Manage_storefront=false;
            if (isMarketplaceUser){ //if user is MP partner user
                String benefitName = checkBenefitLevel(usr); 
                 //IPA 2.0 TWC729-7887	
                //isBasicAccess= benefitName == PMP_StaticConstants_Partner.Solution_Marketplace_Basic_Access? true:false;
                //isEnhanced = benefitName == PMP_StaticConstants_Partner.Solutions_Marketplace_Enhanced? true:false;
                 //IPA 2.0 TWC729-7887	
                //showManageOfferings = /*isEnhanced &&*/ customPermissions.contains('PMP_Manage_Offerings')? true: false;
              //IPA 2.0 TWC729-7887
             //   showManageStorefront= benefitName!=Null  /*&& !isBasicAccess*/? true:false;
			 Map<String, Boolean> mapPermmision = Core_UtilityController.checkForCustomPermission();
			 if(mapPermmision.containsKey('PMP_Manage_Storefront') && mapPermmision.get('PMP_Manage_Storefront') != null){
			  is_PMP_Manage_storefront = true;
			}
			showManageStorefront=is_PMP_Manage_storefront?true:false;
			system.debug('mapPermmision'+mapPermmision);
			system.debug('is_PMP_Manage_storefront'+is_PMP_Manage_storefront);
                 //IPA 2.0 TWC729-7887	
               showManageLeads = customPermissions.contains('PMP_Manage_Leads') /*&& benefitName!=Null && !isBasicAccess*/ ;
                showDashboard= customPermissions.contains('PMP_View_Dashboard') /*&& benefitName!=Null && !isBasicAccess*/;
                //showManageSolutions= customPermissions.contains('PMP_Manage_Solutions');
                jsonResponse.isIPAUser= true; 
            }
            else { //if user is internal user
               // showManageOfferings = customPermissions.contains('PMP_Manage_Offerings');
                showManageLeads = customPermissions.contains('PMP_Manage_Leads');
                showDashboard = customPermissions.contains('PMP_View_Dashboard');
                showManagePartners = customPermissions.contains('PMP_Manage_Partners');
                //showManageSolutions = customPermissions.contains('PMP_Manage_Solutions');
                jsonResponse.isIPAUser = false; 
            }
            
            // navBarDetails.url=System.Label.PMP_CreateOfferingURL;
            // navBarDetails.isVisible=showManageOfferings;
            // navigationBarButtons.put('manageOfferings',navBarDetails );
            
            //PMP_Manage_Leads, populate the url and visibility of manage leads button
            navBarDetails=new NavBarButtonAttributes();
            navBarDetails.url=System.Label.PMP_Partneradmin_Community_URL;
            navBarDetails.isVisible=showManageLeads;
            navigationBarButtons.put('manageLeads', navBarDetails);
            
            //PMP_View_Dashboard, populate the url and visibility of view dashboard  button
            navBarDetails=new NavBarButtonAttributes();
            navBarDetails.url=System.Label.PMP_IPA_Dashboard_Url;
            navBarDetails.isVisible=showDashboard;
            navigationBarButtons.put('viewDashboard', navBarDetails);
            
            
            //PMP_Manage_Storefront, populate the url and visibility of manage storefront button
            navBarDetails=new NavBarButtonAttributes();
            navBarDetails.url=System.Label.PMP_Marketplace_Community_URL + '/partner-edit/'+getCompanyId(usr);
            navBarDetails.isVisible=showManageStorefront;
            navigationBarButtons.put('manageStorefront', navBarDetails);
            
            //PMP_Manage_Solutions, populate the url and visibility of submit solution button
            navBarDetails=new NavBarButtonAttributes();
            navBarDetails.url=System.Label.PMP_Marketplace_Community_URL+System.Label.PSS_Redirecting_to_Manage_Solutions;
            navBarDetails.isVisible=showManageSolutions;
            navigationBarButtons.put('submitSolutions', navBarDetails);
            
            //PMP_Manage_Partners, populate the url and visibility of manage partners button
            navBarDetails=new NavBarButtonAttributes();
            navBarDetails.url=System.Label.PMP_Marketplace_Community_URL+'/partner-edit/PMP_Company__c';
            navBarDetails.isVisible=showManagePartners;
            navigationBarButtons.put('managePartners', navBarDetails);
            
            
            jsonResponse.firstName= usr.FirstName; // send user firstname
            jsonResponse.lastName= usr.LastName; // send user firstname
            jsonResponse.navBarButtons=navigationBarButtons;//send all navigation bar buttons
            jsonResponse.message='JSON response returned';
            
        }
        catch(Exception e){
            //System.debug('Exception in the class PMP_NavigationBarAPIDetails.getNavBarDetails');
            PMP_Utility.logError(e,'PMP_NavigationBarAPIDetails'); 
        }
        return jsonResponse;
        
    }
    
    
    //fetch the active partner user for the given email id 
    public static user fetchUser(String emailId){
        // query user with the given email id  
        List<User> userList= new List<User>();
        try{
              userList= [select id,Name,Email,ContactId,FederationIdentifier,Contact.Email,Contact.Core_eRPM_Person_Id__c,FirstName,LastName,
                       AccountId,Core_IPA_One_Partner_Id__c,IsPortalEnabled,LanguageLocaleKey
                       FROM User  Where Email =: emailId and IsActive =true limit 1];
        }   
        catch(System.QueryException qe) {
            //System.debug(qe.getMessage());
        }
        return userList.size()>0? userList[0]: Null; //return user if found, else return Null
    }
    
    //method return the benefit for the given user 
    public static String checkBenefitLevel(User oUser){
        
        String benefitName = Null;
        if(oUser.Core_IPA_One_Partner_Id__c != null){
            
            //Get Company Info and Benefit details for OPID
            List<PMP_Company__c> companyBenefits = PMP_Utility.getCompanyInfoForOpid(oUser.Core_IPA_One_Partner_Id__c);
            // system.debug('company = ' + companyBenefits);
            if(companyBenefits!=null && !companyBenefits.isEmpty()){
                PMP_Company__c companyBenefit = companyBenefits[0];
                if(companyBenefit.PMP_Benefit_Update_Ind__c != true && companyBenefit.PMP_Partner_Inactive_Ind__c != true){
                    
                    benefitName = companyBenefit.PMP_Partner_Benefit_Type__c;
                    
                }
                
            }                
        }
        if(oUser.AccountId != null){
            //Get Company Info and Benefit details for Location account
            List<PMP_Company__c> locCompanyList;
            try{
                
                List<PMP_OPID_MPI_Rel__c> junctionObjects= PMP_Utility.getJunctionAccountToMpiByAccountId(new Set<Id>{oUser.AccountId});
                List<Id> listMpiIds = PMP_Utility.getListMpiIds(junctionObjects);
                
                if(Schema.sObjectType.PMP_Company__c.isAccessible()){
                    locCompanyList = [SELECT id, PMP_Partner_Benefit_Type__c,PMP_Benefit_Update_Ind__c,PMP_Partner_Inactive_Ind__c
                                      from PMP_Company__c where PMP_Is_Published_Ind__c =true and id in: listMpiIds];   
                } 
            }
            catch(System.QueryException qe) {
                //System.debug(qe.getMessage());
            }
            if(locCompanyList!=null && !locCompanyList.isEmpty() && locCompanyList[0].PMP_Benefit_Update_Ind__c!=true && locCompanyList[0].PMP_Partner_Inactive_Ind__c != true){
                //if(locCompanyList[0].PMP_Benefit_Update_Ind__c!=true && locCompanyList[0].PMP_Partner_Inactive_Ind__c != true){
                    
                    benefitName = locCompanyList[0].PMP_Partner_Benefit_Type__c;
                    
                //}
            }
        }
        
        return benefitName;
    }
    
    
    //method returns the company id for the given user 
    public static String getCompanyId(User usr){
        if(usr.Core_IPA_One_Partner_Id__c != null){
            List<PMP_Company__c> companyInformation = PMP_Utility.getCompanyInfoForOpid(usr.Core_IPA_One_Partner_Id__c);
            if(companyInformation.size()>0){
                PMP_Company__c company = companyInformation[0];
                return company.Id;
            }                                
        }
        return null;
    }
    
    
    //method to will return the custom  marketplace permissions that user has access to
    
    public static List<String> hasPermission(List<String> customPermissionNamesList, User usr) {
        
        List<String> assignedPermissions = new List<String>();
        set<String> customPermissionsForCurrentUser = new Set<String>();
        
        Map<Id, String> customPermissionNamesById = new Map<Id, String>();
        //fetch the given custom permissions
        List<CustomPermission> customPermissions = 
            [select Id, DeveloperName from CustomPermission where DeveloperName in :customPermissionNamesList];
        for(CustomPermission customPermission : customPermissions) {
            customPermissionNamesById.put(customPermission.Id, customPermission.DeveloperName);
        }
        
        // Query to determine which of these custome settings are assigned to this user
        
        //check the custom permissions for the given user user permissionsets
        List<SetupEntityAccess> setupEntities = 
            [SELECT SetupEntityId
             FROM SetupEntityAccess
             WHERE SetupEntityId in :customPermissionNamesById.keySet() AND
             ParentId
             IN (SELECT PermissionSetId 
                 FROM PermissionSetAssignment
                 WHERE AssigneeId = :usr.Id)]; 
        for(SetupEntityAccess setupEntity : setupEntities){
            customPermissionsForCurrentUser.add(customPermissionNamesById.get(setupEntity.SetupEntityId));
        }
        
        //get the user custom permissions 
        for(String customPermissionName : customPermissionNamesList){
            if(customPermissionsForCurrentUser.contains(customPermissionName)){
                assignedPermissions.add(customPermissionName); 
            }
        }
        
        return assignedPermissions;//return the user custom permissions
    }
    
    
    //method return true if use is a ipa partner user
    public static Boolean isMarketplaceUser(User usr){
        
        boolean isMarketplaceUser = false;
        List<PermissionSetAssignment> lstcurrentUserPerSet;
        
        lstcurrentUserPerSet  =  [SELECT Id, PermissionSet.Name,AssigneeId
                                  FROM PermissionSetAssignment
                                  WHERE AssigneeId = :usr.Id];
        
        if(!lstcurrentUserPerSet.isEmpty()){
            for (PermissionSetAssignment psa: lstcurrentUserPerSet)
            {
                if(psa.PermissionSet.Name.equals('PMP_External_Employee')){
                    isMarketplaceUser = true;
                }    
            }        
        }        
        return isMarketplaceUser; // Returing the boolean parameter
    }
    
    
    global class NavBarAPIResponse{
        global String firstName;
        global String lastName ;
        global Boolean isIPAUser;
        global String message;
        global Map<String,NavBarButtonAttributes> navBarButtons;
        
    }
    
    global class NavBarButtonAttributes{
        global String url;
        global Boolean isVisible;
    }
}