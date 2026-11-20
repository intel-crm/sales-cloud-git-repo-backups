/****************************************************************************************************************************************
* Class Name  : Core_ExternalUser_IPS_Project_Controller 
* Version     : 1.0 
* Created Date: 5 Oct 2017
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps            10/5/2017                     Main Controller to create Premier Support Projects As IPS External Customer 
*****************************************************************************************************************************************/
public with sharing class Core_ExternalUser_IPS_Project_Controller{
    public Core_IPS_Project__c ipsProject{get;set;}
    //Constants to Uniquiely identify the step
    public static final String IPS_PROJ           = 'Premier Support Project';
    public static final String IPS_PROJ_MEM       = 'Premier Support Project Members';
    public static final String IPS_PROJ_PROD      = 'Premier Support Products';
    public static String modeStr {get;set;}//Utilizing this Flag to render the UI Components
    public static String editProj {get;set;}
    
    private static final String AVAILABLE_RECORDS = 'AvailableRecords';
    private static final String EXISTING_RECORDS  = 'ExistingRecords';
    private static final String ACTIVE            = 'Active';
    private static final String IN_ACTIVE         = 'InActive';
    
    //Private variables
    private transient List<String>  colNames = null;
    private String loggedInUserAcctId = null;
    private String loggedInUserContId = null;
    private Account loggedinUsrAcct = null;
    
    //public variables    
    public String overrideIndex{get;set;}
    public Map<String, Map<String, Core_CustomSetController>> mStep_SetCntlr {get;set;} 
    public List<String> steps {get;set;}
    public Integer stepIndex {get;set;}
    // start US158228 --22 Nov 2018- add by Orion vamsi
    public User loggedInUser = [Select Id, Name,profileId, ContactId, Contact.AccountId From User where Id =: UserInfo.getUserId()];
    public list<PermissionSetAssignment> userPerSet;
    // END US158228 --22 Nov 2018- add by Orion vamsi
    public User getLoggerInUser(){ return loggedInUser;}
    public transient String btnActionSource {get;set;}
    
    //start US158228 --22 Nov 2018- add by Orion vamsi
    public string selectedUser{set;get;}
    public boolean fieldDisplay{set;get;}
    String FAEPermissionSetId = System.Label.Core_IPS_Partner_DFAE_Permission_Set;
    String agentPartnerProfileId=System.Label.Core_IPS_Partner_AE_Profile_Id;
     
    // END US158228 --22 Nov 2018- add by Orion vamsi
    //Start --US240404--26-Dec-18 for Disabling InterestedParty checkbox by Popcornapps
    public list<Contact> lstCon{set;get;}
    public boolean isEmailOptCheck{set;get;}
    
    //Lazy loading
    public String IPSProductBasicRecordType{ get{
        if(IPSProductBasicRecordType == null){
            try{
                IPSProductBasicRecordType = [SELECT Id FROM RecordType where SobjectType = 'Core_IPS_Product__c' AND DeveloperName = 'Core_IPS_Project_Product'].Id;   
            }catch(Exception e){ 
                IPSProductBasicRecordType = '';
            }
        }
        return IPSProductBasicRecordType;
    }  private set;}
    
    //Initializing Set Controller
    public void initialize(){
        loggedInUserAcctId = loggedInUser.Contact.AccountId;
        loggedInUserContId = loggedInUser.ContactId ;
        String query = null;
        String searchQuery = null;
        String iipsProjectrojId;
        
        
        iipsProjectrojId = (ipsProject.Id == null ? '' : ipsProject.Id);
        Core_CustomSetController cont = null;
        
        Map<String, Core_CustomSetController>  mTable_SetCntrlr = null;
        mStep_SetCntlr = new Map<String, Map<String, Core_CustomSetController>>();        
        
        overrideIndex = ApexPages.currentPage().getParameters().get('stepIndex');
        stepIndex = String.isNotBlank(overrideIndex) ? Integer.valueOf(overrideIndex) : 0; 
        //**************************************** STEP 2 **************************************** //
        //****************  set controller to Show existing Project Members ************/        
        colNames = new List<String>{'Core_IPS_Contact__r.FirstName', 'Core_IPS_Contact__r.LastName','Core_IPS_Contact__r.Email','Core_Status__c'};
            
            query = 'Select Core_IPS_Contact__c,Core_Status__c,Core_IPS_Contact__r.FirstName,Core_IPS_Contact_Account__c, Core_IPS_Contact__r.LastName, Core_IPS_Contact__r.Email, Core_IPS_Contact__r.Account.Name '+
            ' FROM Core_IPS_Project_Member__c WHERE  Core_Status__c = \'ACTIVE\' AND  Core_IPS_Contact__r.AccountId  =\''+loggedInUserAcctId+'\'  AND Core_IPS_Project__c = \''+(ipsProject.Id == null ? '' :ipsProject.Id)+'\'';
        cont = new Core_CustomSetController(query, colNames, true, false, 'Core_IPS_Contact__r.Name');
        
        mTable_SetCntrlr = new Map<String, Core_CustomSetController>();
        mTable_SetCntrlr.put(EXISTING_RECORDS, cont);
        
        //**************** Current set controller to show Available contacts for adding to project Members ************/
        colNames = new List<String>{'FirstName','LastName','Email','Account.Name'};
            
            query = 'Select LastName, FirstName,Core_Status__c, Email, Account.Name, Core_IPS_Active__c,Core_IPS_Email_Opt_Out__c From Contact Where AccountId = \''+loggedInUserAcctId+'\' AND ID != \''+loggedInUserContId+'\'  AND Core_IPS_Active__c  = true  ';
        query += ' AND ID NOT IN ( Select Core_IPS_Contact__c FROM Core_IPS_Project_Member__c where  Core_Status__c = \'ACTIVE\' AND Core_IPS_Project__c = \''+iipsProjectrojId+'\') And ID in (SELECT ContactId FROM User WHERE IsActive = true)';
        
        cont = new Core_CustomSetController(query, colNames, true, false, 'Name, email');
        
        mTable_SetCntrlr.put(AVAILABLE_RECORDS, cont);
        mStep_SetCntlr.put(IPS_PROJ_MEM, mTable_SetCntrlr);
        
        //******************** STEP 3 ******************** //
        //****************  set controller to Show existing IPS Products************/     
        colNames = new List<String>{ 'Core_Supported_Product_Name__c', 'Core_IPS_Product_Status__c' , 'Product_Application__c' };
            query = 'Select Name, Core_Supported_Product_Name__c,Core_IPS_Product_Status__c, Core_Intel_Product__c,Product_Application__c, Core_Supported_Product__c  '+
            'FROM Core_IPS_Product__c where Core_IPS_Product_Status__c = \'ACTIVE\' AND  Core_IPS_Project__c = \''+iipsProjectrojId+'\'';
        cont = new Core_CustomSetController(query, colNames, true, false, 'Name,Core_Supported_Product_Name__c,Product_Application__c');
        
        mTable_SetCntrlr = new Map<String, Core_CustomSetController>();
        mTable_SetCntrlr.put(EXISTING_RECORDS, cont);
        mStep_SetCntlr.put(IPS_PROJ_PROD, mTable_SetCntrlr);
        
        //****************  set controller to Show Available IPS Products************/     
        //Create set controller for Adding Products
        colNames = new List<String>{ 'Name', 'Status','core_Product_Application__c' };
            query = 'Select Name,Account.Name, Core_Supported_Product__r.Core_Product_Organization__r.Name,core_Product_Application__c, Core_Supported_Product__r.Core_Flag_Status__c, '+
            'Core_Code_Name__c,  InstallDate, Status, Description, Core_IPS_Asset__c, Core_IPS_Project__c, Core_Supported_Product__c, Core_Product_Organization__c '+
            'From Asset '+
            'Where (AccountId = \''+loggedInUserAcctId+'\' or RecordType.Name = \'Public Products\' or Core_IPS_Project__c = Null ) AND status = \'Active\' AND Core_IPS_Supported_Product_EOIS__c = false AND '+
            'Core_Supported_Product__C NOT IN ( Select Core_Supported_Product__c FROM Core_IPS_Product__c WHERE Core_IPS_Product_Status__c = \'ACTIVE\' AND Core_IPS_Project__c = \''+iipsProjectrojId+'\')';    
        cont = new Core_CustomSetController(query, colNames, true, false, 'Name,core_Product_Application__c');
        
        mTable_SetCntrlr.put(AVAILABLE_RECORDS, cont);
        mStep_SetCntlr.put(IPS_PROJ_PROD, mTable_SetCntrlr);
        //To get the URL parameters to hide/show pageblocks in Remove(Inactivate) Products/Members scenario      
        modeStr  = ApexPages.currentPage().getParameters().get('modeStr');
        editProj = ApexPages.currentPage().getParameters().get('editProj');
    }
    // Start US158228 --22 Nov 2018- add by Orion vamsi -- display values in PSO drop down list
    public List<SelectOption> getdynamiclist() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--None--'));
        options.add(new SelectOption(loggedInUser.Id,loggedInUser.Name));
        return options;
    }
    // END US158228 --22 Nov 2018- add by Orion vamsi
    //Constructor
    public Core_ExternalUser_IPS_Project_Controller(ApexPages.StandardController stdCntrlr){
        //Start --US240404--26-Dec-18 for Disabling InterestedParty checkbox by Popcornapps
        isEmailOptCheck=false;
        getContactData();
       // Start US158228 --22 Nov 2018- add by Orion vamsi to display or not PSO field 
         userPerSet=[Select PermissionSetID From PermissionSetAssignment where AssigneeId=:UserInfo.getUserId() ]; 
        if(loggedInUser.profileId ==agentPartnerProfileId || userPerSet[0].PermissionSetID == FAEPermissionSetId ){
        fieldDisplay=true;
    }else{
        fieldDisplay=false;
    }
    // END US158228 --22 Nov 2018- add by Orion vamsi
        ipsProject = (Core_IPS_Project__c) stdCntrlr.getRecord();
        if(ipsProject != null && String.isNotBlank(ipsProject.Id)){
            try{ 
                //ReQuery for the additional fields 
                ipsProject = [Select c.Core_MPNDA__c, c.Core_IPS_Project_ID__c, RecordTypeId, Name, Core_IPS_GroupId__c, Core_Project_Description__c, Core_Status__c 
                              From Core_IPS_Project__c c where Id =: ipsProject.Id]; 
                
            }catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            }
        }else{
            ipsProject = new Core_IPS_Project__c();
        }
        stepIndex = 0;
        steps = new list<String> { IPS_PROJ , IPS_PROJ_MEM , IPS_PROJ_PROD };
            
            
            if(loggedInUser.Contact.AccountId == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid community user or user not authorized '));                
            }
        else{
            
            initialize();
            
            //Read Values from URL Paramters
            String ind = ApexPages.currentPage().getParameters().get('stepIndex');
            String iipsProjectrojectId = ApexPages.currentPage().getParameters().get('Core_IPS_Project__c'); 
            stepIndex = String.isNotBlank(ind) ? Integer.valueOf(ind) : 0;       
        }
    }
    
    //Method Call when Previous Step Button is Clicked 
    public PageReference previousStep(){
        modeStr = 'add';
        stepIndex = stepIndex-1;
        stepIndex = stepIndex < 0 ? 0: stepIndex;
        return null;
    }
    
    // Method Call when Next/Save&Continue Button is Clicked
    public void nextStep(){ 
        modeStr = 'add';
        stepIndex +=1;
    }
    
    //Inserting IPS Project
    private void createIPSProject(){
        /*US1021248 - 05/28/2021 - Vishal - FLS Check for security vulnerability --*/
        if (Schema.sObjectType.Core_IPS_Project__c.fields.Core_Status__c.isCreateable() || Schema.sObjectType.Core_IPS_Project__c.fields.Core_Status__c.isUpdateable()) {
            ipsProject.Core_Status__c = 'New';
        }
       //if(String.isBlank(ipsProject.Core_MPNDA__c))
        //ipsProject.Core_MPNDA__c = '';
        upsert ipsProject;
        Map<Id, Core_IPS_Project__c> mipsProject = new Map<Id, Core_IPS_Project__c>();
        mipsProject.put(ipsProject.id, ipsProject);
        Core_ExternalUser_IPS_Project_Helper.createAccountOnProjectCreationForExternalCustomer(mipsProject, loggedInUser);
    }
    
    //Method Call when Save Button is Clicked
    public PageReference saveAll(){
        modeStr = 'add';
        PageReference pr;
        try{
            if (mStep_SetCntlr.get(steps[stepIndex]).get(AVAILABLE_RECORDS).selectedRecords.isEmpty()) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Please select atleast one Product'));
                return null;
            } 
            else{
                //Create Project 
                createIPSProject();
                /*US1021248 - 05/28/2021 - Vishal - FLS Check for security vulnerability --*/
                if (Schema.sObjectType.Core_IPS_Project__c.fields.Core_Status__c.isCreateable() || Schema.sObjectType.Core_IPS_Project__c.fields.Core_Status__c.isUpdateable()) {
                    ipsProject.Core_Status__c = 'Active';
                }
                //  US158228 --22 Nov 2018- add by Orion vamsi to show selected user as PSO
                if (Schema.sObjectType.Core_IPS_Project__c.fields.Core_IPS_Partner_Support_Owner__c.isCreateable() || Schema.sObjectType.Core_IPS_Project__c.fields.Core_IPS_Partner_Support_Owner__c.isUpdateable()) {
                    ipsProject.Core_IPS_Partner_Support_Owner__c=selectedUser;
                }
                upsert ipsProject;
                //Add members to Project
                Stepindex = 1;
                upsertProjectMembers();
                //Add IPS Products to Project  
                Stepindex = 2;
                upsertIPSProducts();
                upsertAsserts();
            }
            pr = new PageReference('/a2B/o');//RK added this for US104706 to redirect users to list view page after Project creation to provide system sufficient time to load Project Assets.
        }
        
        catch(System.DMLException e){
            Stepindex = 0;
            pr =  null;
        }
        return pr;
    }
    
    //Method to call when Buttons Add Members/Remove Members Add Products/Remove Products
    public PageReference updateRecords(){ 
        PageReference pr;
        modeStr = ApexPages.currentPage().getParameters().get('modeStr');//US104706
        
        if(steps[stepIndex] == IPS_PROJ_PROD){
            upsertIPSProducts();
            upsertAsserts();
            pr =  modeStr =='add' ? new PageReference('/IPS/a2B/o') : new PageReference('/'+ipsProject.Id); //RK added this for US104706 to redirect users to list view page after Project creation to provide system sufficient time to load Project Assets.
            
            
        }else if(steps[stepIndex] == IPS_PROJ_MEM){
            upsertProjectMembers();
            pr = new PageReference('/'+ipsProject.Id);//RK added this for US104706 to redirect users to list view page after Project creation to provide system sufficient time to load Project Assets.
        }        
        return pr;
    }
    
    /** Pagination buttons for the table that shows available items for selection  **/
    public void firstPage(){        
        mStep_SetCntlr.get(steps[stepIndex]).get(btnActionSource).sobjectRecords = null;
        mStep_SetCntlr.get(steps[stepIndex]).get(btnActionSource).setCntrlr.first();  
    }
    public void previousPage(){        
        mStep_SetCntlr.get(steps[stepIndex]).get(btnActionSource).sobjectRecords = null;
        mStep_SetCntlr.get(steps[stepIndex]).get(btnActionSource).setCntrlr.previous();  
    }
    public void nextPage(){
        mStep_SetCntlr.get(steps[stepIndex]).get(btnActionSource).sobjectRecords = null;
        mStep_SetCntlr.get(steps[stepIndex]).get(btnActionSource).setCntrlr.next(); 
    }
    public void lastPage(){
        mStep_SetCntlr.get(steps[stepIndex]).get(btnActionSource).sobjectRecords = null;
        mStep_SetCntlr.get(steps[stepIndex]).get(btnActionSource).setCntrlr.last();     
    }
    
    public void reset(){
        mStep_SetCntlr.get(steps[stepIndex]).get(btnActionSource).setCntrlr = null;
    }
    
    //This Method Updates records in the Selected table when records are selected/Unselected from Available records table
    public void updateSelectedRecords(){
        modeStr  = ApexPages.currentPage().getParameters().get('modeStr');          
        Core_CustomSetController Con = (modeStr =='remove') ? mStep_SetCntlr.get(steps[stepIndex]).get(EXISTING_RECORDS) 
            : mStep_SetCntlr.get(steps[stepIndex]).get(AVAILABLE_RECORDS) ;
        
        for(Core_CustomSetController.Wrapper w : con.sobjectRecords){ 
            if(w.selected == true){
                con.selectedRecords.put(w.sobj.Id, new Core_CustomSetController.Wrapper(w.sobj, true));
            }else if(w.selected == false && con.selectedRecords.containsKey(w.sobj.Id)){
                con.selectedRecords.remove(w.sobj.Id);
            }
        }
    }
    
    
    //Insert Project Members,Activate Members
    public void upsertProjectMembers(){
        List<Core_IPS_Project_Member__c> lProjMembers = new List<Core_IPS_Project_Member__c>();
        Set<Id> sContIds = new Set<ID>();
        Core_CustomSetController sc = mStep_SetCntlr.get(steps[stepIndex]).get(AVAILABLE_RECORDS);
        Map<Id, Id> mContIdips_ProjectId = Core_ExternalUser_IPS_Project_Helper.getExistingMembers(ipsProject.Id);
        for(Core_CustomSetController.Wrapper w: sc.getAllSelectedRecords()){
            sContIds.add(w.sobj.Id);
        }
        
        //Retrieve User Records
        Map<Id, Id> mContIdUserId = Core_ExternalUser_IPS_Project_Helper.getContactUserRecordIds(sContIds);
        
        for(Core_CustomSetController.Wrapper w: sc.getAllSelectedRecords()){
            Core_IPS_Project_Member__c pm = new Core_IPS_Project_Member__c();
            /*US1021248 - 05/28/2021 - Vishal - FLS Check for security vulnerability --*/
            if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_IPS_Contact__c.isCreateable() || Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_IPS_Contact__c.isUpdateable()) {
                pm.Core_IPS_Contact__c = w.sobj.Id;
            }
            if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_Selective_Member__c.isCreateable() || Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_Selective_Member__c.isUpdateable()) {
                pm.Core_Selective_Member__c = true;
            }
            if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_Status__c.isCreateable() || Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_Status__c.isUpdateable()) {
                pm.Core_Status__c = 'Active';
            }
            if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_User__c.isCreateable() || Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_User__c.isUpdateable()) {
                pm.Core_User__c = mContIdUserId.get(w.sobj.id);
            }
            if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_IPS_Project__c.isCreateable() || Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_IPS_Project__c.isUpdateable()) {
                pm.Core_IPS_Project__c = ipsProject.Id;
            }
            if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Id.isCreateable() || Schema.sObjectType.Core_IPS_Project_Member__c.fields.Id.isUpdateable()) {
                pm.Id = mContIdips_ProjectId.get(w.sobj.Id);
            }
            lProjMembers.add(pm);
        }
        upsert lProjMembers;
    }
    
    //Insert IPS Products Products
    public void upsertIPSProducts(){
        List<Core_IPS_Product__c> lIPSProducts = new List<Core_IPS_Product__c>();
        Core_CustomSetController sc = mStep_SetCntlr.get(steps[stepIndex]).get(AVAILABLE_RECORDS);
        Core_IPS_Product__c prod = null;
        Map<Id, Core_IPS_Product__c> mSuppProd_ipsProd = Core_ExternalUser_IPS_Project_Helper.getAllInActiveIPSProducts(ipsProject.Id);
        
        for(Core_CustomSetController.Wrapper w: sc.getAllSelectedRecords()){
            Asset assetObj = (Asset)w.sobj;
            prod = mSuppProd_ipsProd.get(assetObj.Core_Supported_Product__c);
            if(prod == null){
                prod = new Core_IPS_Product__c();
                /*US1021248 - 05/28/2021 - Vishal - FLS Check for security vulnerability --*/
                if (Schema.sObjectType.Core_IPS_Product__c.fields.Core_IPS_Project__c.isCreateable() || Schema.sObjectType.Core_IPS_Product__c.fields.Core_IPS_Project__c.isUpdateable()) {
                    prod.Core_IPS_Project__c = ipsProject.Id;
                }  

            }
            /*US1021248 - 05/28/2021 - Vishal - FLS Check for security vulnerability --*/
            if (Schema.sObjectType.Core_IPS_Product__c.fields.Core_Supported_Product__c.isCreateable() || Schema.sObjectType.Core_IPS_Product__c.fields.Core_Supported_Product__c.isUpdateable()) {
                prod.Core_Supported_Product__c = assetObj.Core_Supported_Product__c;
            }
            if (Schema.sObjectType.Core_IPS_Product__c.fields.Core_IPS_Product_Status__c.isCreateable() || Schema.sObjectType.Core_IPS_Product__c.fields.Core_IPS_Product_Status__c.isUpdateable()) {
                prod.Core_IPS_Product_Status__c ='Active';
            }
            if (Schema.sObjectType.Core_IPS_Product__c.fields.Status__c.isCreateable() || Schema.sObjectType.Core_IPS_Product__c.fields.Status__c.isUpdateable()) {
                prod.Status__c = 'Approved';
            }
            if (Schema.sObjectType.Core_IPS_Product__c.fields.Core_IPS_IsAutoApprove__c.isCreateable() || Schema.sObjectType.Core_IPS_Product__c.fields.Core_IPS_IsAutoApprove__c.isUpdateable()) {
                prod.Core_IPS_IsAutoApprove__c = true;
            }
            if (Schema.sObjectType.Core_IPS_Product__c.fields.Core_Intel_Product__c.isCreateable() || Schema.sObjectType.Core_IPS_Product__c.fields.Core_Intel_Product__c.isUpdateable()) {
                prod.Core_Intel_Product__c  = assetObj.Id;
            }
            if (Schema.sObjectType.Core_IPS_Product__c.fields.Core_IsSubmitted_Header__c.isCreateable() || Schema.sObjectType.Core_IPS_Product__c.fields.Core_IsSubmitted_Header__c.isUpdateable()) {
                prod.Core_IsSubmitted_Header__c = true;
            }
            if(String.isNotBlank(IPSProductBasicRecordType)){
                if (Schema.sObjectType.Core_IPS_Product__c.fields.RecordTypeId.isCreateable() || Schema.sObjectType.Core_IPS_Product__c.fields.RecordTypeId.isUpdateable()) {
                    prod.RecordTypeId  = IPSProductBasicRecordType;
               }
            }
                
            lIPSProducts.add(prod);
        }
        upsert lIPSProducts;
        if(lIPSProducts.size()!=null){
            updateAssertsStatus(lIPSProducts);
        }        
    }
    
    //Inactivate all the selected assets
    public void upsertAsserts(){
        Core_CustomSetController sc = mStep_SetCntlr.get(steps[stepIndex]).get(EXISTING_RECORDS);
        List<SOBject> assetsToInactivate = new List<SOBject>();
        for(Core_CustomSetController.Wrapper w : sc.sobjectRecords){
            if(w.selected == true){
                w.sobj.put('Core_IPS_Product_Status__c', 'InActive');
                assetsToInactivate.add(w.sobj);
            }
        }
        update assetsToInactivate;
    } 
    
    //Updating the Intel Product Status when Upserting IPS Products
        public void updateAssertsStatus(List<Core_IPS_Product__c> lIPSProducts){
        Map<Id, Core_IPS_Product__c> ipsProdMap;
        List <Asset> lAssetsToActivate = new List<Asset>();  
        Set<Id> ipsSupProdIdSet = new Set<Id>();
        if(lIPSProducts!=null) {
            Map<Id,Core_IPS_Product__c> ipsProdMapNew =  new Map<Id,Core_IPS_Product__c>();
            ipsProdMapNew.putAll(lIPSProducts); 
           if(Core_IPS_Product__c.SObjectType.getDescribe().isAccessible()){
            ipsProdMap = new Map<Id, Core_IPS_Product__c>([SELECT Name,Id,Core_Supported_Product__R.Id,Core_Intel_Product__C FROM Core_IPS_Product__c WHERE Id IN :ipsProdMapNew.keySet()]);
            }
            for(Id ipsProdId : ipsProdMap.keySet()) {
                ipsSupProdIdSet.add(ipsProdMap.get(ipsProdId).Core_Supported_Product__R.Id);
            }
            Map<Id, Asset> assetMap = new Map<Id, Asset>([SELECT Id, Status, UsageEndDate, Core_Supported_Product__R.Id FROM Asset WHERE Core_Supported_Product__R.Id IN:ipsSupProdIdSet AND Core_IPS_Project__R.Id =:ipsProject.Id]);
            Map<Id, Asset> supProdAssetMap = new Map<Id, Asset>();
            for(Id assetId : assetMap.keySet()) {
                supProdAssetMap.put(assetMap.get(assetId).Core_Supported_Product__R.Id, assetMap.get(assetId) );
            }
            for(Id ipsProdId : ipsProdMap.keySet()) {
                Asset assetActivate = supProdAssetMap.get(ipsProdMap.get(ipsProdId).Core_Supported_Product__R.Id);
                /*--- Start US1038641 06/24/2021 - Farhaad - FLS Check for security vulnerability--*/
                if (Schema.sObjectType.Asset.fields.Status.isCreateable() || Schema.sObjectType.Asset.fields.Status.isUpdateable()) {
                    assetActivate.Status = 'Active';
                }
                /*--- End US1038641 06/24/2021 - Farhaad - FLS Check for security vulnerability--*/
                lAssetsToActivate.add(assetActivate);
            }
        }
        if(lAssetsToActivate != null && !lAssetsToActivate.isEmpty()){
            upsert lAssetsToActivate;
        }
    }
    
    //Method to remove Members from an Existing Project
    public PageReference removeMembers(){
        PageReference pr;
        string  projOwnerName;
        Set<Id> sContIds = new Set<ID>();
        
        //Retrieve User Records
        Map<Id, Id> mContIdUserId = Core_ExternalUser_IPS_Project_Helper.getContactUserRecordIds(sContIds);
        Core_CustomSetController sc = mStep_SetCntlr.get(steps[stepIndex]).get(EXISTING_RECORDS);
        for(Core_CustomSetController.Wrapper w: sc.getAllSelectedRecords()){
            sContIds.add(w.sobj.Id);
        }
        
        sc = mStep_SetCntlr.get(steps[stepIndex]).get(EXISTING_RECORDS);
        sContIds = new Set<ID>();
        for(Core_CustomSetController.Wrapper w: sc.sobjectRecords){
            if(w.selected == true)
                sContIds.add(w.sobj.Id);
        }
        List<Core_IPS_Project_Member__c> lstInactivate = [Select Id,Core_IPS_Project__R.Id,Core_IPS_Project__R.OwnerId,Core_User__R.Id,Core_Status__c,Core_User__R.Name FROM Core_IPS_Project_Member__c where ID IN : sContIds ];
        
        for(Core_IPS_Project_Member__c p : lstInactivate){
            if(p.Core_IPS_Project__R.OwnerId == p.Core_User__c){        
                projOwnerName =p.Core_User__R.Name ;
            }else{
                p.Core_Status__c = 'InActive';
            }
        }
        If(String.isNotBlank(projOwnerName)){
            modeStr = 'remove';
            editProj =  'true';
            pr = null;
            
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'You cannot remove the owner of a project: '+projOwnerName+' .<br/> If you would like to remove this user from this project, please contact your Intel Representative to change the owner to a different user.'));       
            
        }
        else{
            update lstInactivate;
            pr = new PageReference('/'+ipsProject.Id); 
        }
        return pr;
    }
    //Start --US240404--26-Dec-18 for Disabling InterestedParty checkbox by Popcornapps
     Public void getContactData(){
        lstCon=[SELECT Id,FirstName,LastName,Email,Core_IPS_Email_Opt_Out__c FROM Contact WHERE (ID In (SELECT ContactID FROM User WHERE id=:userinfo.getuserid()))];
        if(lstCon != null && !lstCon.isEmpty())
        {
            if(lstCon[0].Core_IPS_Email_Opt_Out__c == True)
            {
                isEmailOptCheck = True;
            }
        }
        }
        //End --US240404--26-Dec-18 for Disabling InterestedParty checkbox by Popcornapps
}