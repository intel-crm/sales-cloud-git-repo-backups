/**********************************************************************************************************************
   Name:            GEN_SearchReferenceController.cls 
   Description:     Controller for GEN_SearchReference Page  
                                         
   Date             Version     Author              Summary of Changes 
   -----------      ---------- --------------------------------------------------------------------------------------------------------------------
   Sep 2020         1.0         Mitesh Dedhia      Intial Version

**********************************************************************************************************************/

public class GEN_SearchLicenseController{
    
    
    public String contactId; // All queries are done based on this Id
    public Sales_License_Admin_Delegate__c adminDelegate{ get; set; } // used for User__c field
    public List<Sales_License__c> licenseList {get;set;} // To store groups user is added to
    public String licenseId{get;set;} // used to store group & queue id when user clicks on them
    public Set<Id> primaryAndDelegateContactID ;
    //public String exportObject {get;set;} // to identofy what needs to be exported
    //public String csvString{get;set;} // to create csv string for export
    //public String exportFileName{get;set;} // to create dynamic file name for export
    public String themeDisplayedType; // to create URls based on user theme
    public String errorMessage{get;set;} // to display error messages
    
    /**********************************************************************************************************************
    * author: Mitesh Dedhia
    * Date: Sep 2020
    * Param: NA
    * Return: NA
    * Description: Constructor of the Controller
    * High Level Process :
    * Summary of Changes : 
    **********************************************************************************************************************/
    public GEN_SearchLicenseController(){
        
        themeDisplayedType = UserInfo.getUIThemeDisplayed();
                errorMessage='';
        contactId = '';
        primaryAndDelegateContactID = new Set<Id>();
        
        adminDelegate = new Sales_License_Admin_Delegate__c();
        licenseList = new List<Sales_License__c>();
        
        System.debug('contactId>>>>'+contactId);
        
    }
    
    /**********************************************************************************************************************
    * author: Mitesh Dedhia
    * Date: Sep 2020
    * Param: NA
    * Return: PageReference
    * Description: call all methods to fetch details for the user being searched
    * High Level Process :
    * Summary of Changes : 
    **********************************************************************************************************************/
    public PageReference searchLicenses(){
        contactId='';
        
        // Assign id of teh user being searched
        if(String.isBlank(contactId)){
            contactId = adminDelegate.Sales_License_PrimaryAdmin_Contact__c;
        }
        System.debug('contactId>>>'+contactId);
        
        //blank all variables if User Id is blank
        if(String.isBlank(contactId)){
            licenseList = new List<Sales_License__c>();
            errorMessage = 'Please Select Contact'; // If button is clicked without selecting user
        }
        else{
            errorMessage = '';
            
            licenseList = fetchLicenseDetails();   
           
           }
        return null;   
    }
    
    
    
    /**********************************************************************************************************************
    * author: Mitesh Dedhia
    * Date: Sep 2020
    * Param: NA
    * Return: List<GroupMember>
    * Description: Fetch public groups user is added to 
    * High Level Process :
    * Summary of Changes : 
    **********************************************************************************************************************/
    public List<Sales_License__c> fetchLicenseDetails(){
    primaryAndDelegateContactID = new Set<Id>();
        for(Sales_License_Admin_Delegate__c delegateAdminRecord: [Select id,Sales_License_PrimaryAdmin_Contact__c,Sales_License_PrimaryAdmin_Contact__r.Name,
        Sales_License_DlgAdmin_Contact__c,Sales_License_DlgAdmin_Contact__r.Name from Sales_License_Admin_Delegate__c where Sales_License_DlgAdmin_Contact__c =: contactId OR Sales_License_PrimaryAdmin_Contact__c =: contactId]){
            System.debug('delegateAdminRecord.Sales_License_PrimaryAdmin_Contact__c>>'+delegateAdminRecord.Sales_License_PrimaryAdmin_Contact__c);
            if(String.isNotBlank(delegateAdminRecord.Sales_License_PrimaryAdmin_Contact__c)){
                primaryAndDelegateContactID.add(delegateAdminRecord.Sales_License_PrimaryAdmin_Contact__c);
            }
            //primaryAndDelegateContactID.add(delegateAdminRecord.Sales_License_DlgAdmin_Contact__c);
        }
        
        if(primaryAndDelegateContactID != null){
            licenseList = [Select id,Name from Sales_License__c where Sales_License_Primary_Admin_Contact__c IN : primaryAndDelegateContactID OR Sales_License_Lic_User_Contact_ID__c =: contactId limit 1000];
        }   
    
        
        if(licenseList!= null && !licenseList.isEmpty()){
            return licenseList;
        }
        
        else{   
            if(String.isNotBlank(errorMessage)){
                errorMessage = errorMessage + '\n No Licenses Found';
            }
            else{
                errorMessage = 'No Licenses Found';
            }
            
        }
        return null ;
    }   
    
    /**********************************************************************************************************************
    * author: Mitesh Dedhia
    * Date: Sep 2020
    * Param: NA
    * Return: PageReference
    * Description: redirect to public groups user is added to 
    * High Level Process :
    * Summary of Changes : 
    **********************************************************************************************************************/
    /*public PageReference redirecttoPublicGroup(){
        PageReference redirectuser;
        if(themeDisplayedType =='Theme3'){
             redirectuser = new PageReference('/setup/own/groupdetail.jsp?id='+groupId+'&setupid=PublicGroups');
        }
        else if(themeDisplayedType == 'Theme4d'){
            redirectuser = new PageReference('/lightning/setup/PublicGroups/page?address=%2Fsetup%2Fown%2Fgroupdetail.jsp%3Fid%3D'+groupId);
        }
        redirectuser.setredirect(true);
        return redirectuser ;   
    }
    */
    
    
    
    /**********************************************************************************************************************
    * author: Mitesh Dedhia
    * Date: Sep 2020
    * Param: NA
    * Return: PageReference
    * Description: export details in csv format
    * High Level Process :
    * Summary of Changes : 
    **********************************************************************************************************************/
    /*public PageReference exportCSV(){
        String header = '';
        exportFileName = '';
        
        System.debug('exportObject>>>> '+exportObject );
        if(exportObject == 'PublicGroup'){
            header = 'Id, Name \n';
            csvString = header ;
            for(GroupMember groupMemberExport : groupMemberList){
                string recordString = '"'+groupMemberExport.Group.id+'","'+groupMemberExport.Group.Name+'"\n';
                csvString = csvString +recordString;
                
                exportFileName = userDetails[0].Name +'_'+exportObject+'_'+System.now();
            }
        }
        
        if(exportObject == 'Queue'){
            header = 'Id, Name \n';
            csvString = header ;
            for(GroupMember queueMemberExport : queueMemberList){
                string recordString = '"'+queueMemberExport.Group.id+'","'+queueMemberExport.Group.Name+'"\n';
                csvString = csvString +recordString;
                exportFileName = userDetails[0].Name +'_'+exportObject+'_'+System.now();
            }
        }
        
        if(exportObject == 'ReportsTo'){
            header = 'Id, Name, Active, Profile, Market, Manager, Role \n';
            csvString = header ;
            for(User userExport : userIsManagerOf){
                string recordString = '"'+userExport.id+'","'+userExport.Name+'","'+userExport.isActive+'","'+userExport.Profile.name+'","'+userExport.Opco__c+'","'+userExport.Manager.name+'","'+userExport.UserRole.Name+'"\n';
                csvString = csvString +recordString;
                exportFileName = userDetails[0].Name +'_'+exportObject+'_'+System.now();
            }
        }
        
        if(exportObject == 'PSAssigned'){
            header = 'Id, Name \n';
            csvString = header ;
            for(PermissionSetAssignment psAssigned : permissionSetAssignmentList){
                string recordString = '"'+psAssigned.PermissionSetId+'","'+psAssigned.PermissionSet.Name+'"\n';
                csvString = csvString +recordString;
                exportFileName = userDetails[0].Name +'_'+exportObject+'_'+System.now();
            }
        }
        
        if(exportObject == 'ObjectPermission'){
            header = 'PermissionSetId, PermissionSetName, SobjectType, PermissionsRead, PermissionsCreate, PermissionsEdit, PermissionsDelete,PermissionsViewAllRecords,PermissionsModifyAllRecords \n';
            csvString = header ;
            for(ObjectPermissions objPermission : objectPermissionsPS){
                string recordString = '"'+objPermission.ParentId+'","'+objPermission.Parent.Name
                                        +'","'+objPermission.SObjectType+'","'+objPermission.PermissionsRead
                                        +'","'+objPermission.PermissionsCreate+'","'+objPermission.PermissionsEdit
                                        +'","'+objPermission.PermissionsDelete+'","'+objPermission.PermissionsViewAllRecords
                                        +'","'+objPermission.PermissionsModifyAllRecords+'"\n';
                csvString = csvString +recordString;
                exportFileName = userDetails[0].Name +'_'+exportObject+'_'+System.now();
            }
        }
        
        if(exportObject == 'FieldPermission'){
            header = 'PermissionSet Id,PermissionSet Name, SobjectType, Field, PermissionsRead, PermissionsEdit \n';
            csvString = header ;
            for(FieldPermissions fldPermission : fieldPermissionsPS){
                string recordString = '"'+fldPermission.ParentId+'","'+fldPermission.Parent.Name
                                        +'","'+fldPermission.SObjectType+'","'+fldPermission.Field
                                        +'","'+fldPermission.PermissionsRead+'","'+fldPermission.PermissionsEdit
                                        +'"\n';
                csvString = csvString +recordString;
                if(String.isNotBlank(searchField)){
                    exportFileName = searchField+'_'+exportObject+'_'+System.now();
                }
                else{
                    exportFileName = userDetails[0].Name +'_'+exportObject+'_'+System.now();
                }
            }
        }
        
        PageReference myVFPage = new PageReference('/apex/GEN_ExportReference');
        return myVFPage;
    }*/
    
    
}