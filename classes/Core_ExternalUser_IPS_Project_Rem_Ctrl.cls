/****************************************************************************************************************************************
* Class Name  : Core_ExternalUser_IPS_Project_Controller 
* Version     : 1.0 
* Created Date: 5 Oct 2017
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         10/5/2017               Main Controller to create Premier Support Projects As IPS External Customer 
*****************************************************************************************************************************************/
public with sharing class Core_ExternalUser_IPS_Project_Rem_Ctrl{
    public Core_IPS_Project__c ipsProject{get;set;}
    //Constants to Uniquiely identify the step
    public static final String IPS_PROJ           = 'Premier Support Project';
    public static final String IPS_PROJ_MEM       = 'Premier Support Project Members';
    public static final String IPS_PROJ_PROD      = 'Premier Support Products';
    public static String modeStr {get;set;}//Utilizing this Flag to render the UI Components
    public static String projOwnerId {get;set;}
    
    
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
    public User loggedInUser = [Select Id, Name, ContactId, Contact.AccountId From User where Id =: UserInfo.getUserId()];
    public User getLoggerInUser(){ return loggedInUser;}
    public transient String btnActionSource {get;set;}
    
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
        System.debug('  \n initialize METHOD  IipsProjectroject object : '+ipsProject);
        Core_CustomSetController cont = null;
        
        Map<String, Core_CustomSetController>  mTable_SetCntrlr = null;
        mStep_SetCntlr = new Map<String, Map<String, Core_CustomSetController>>();        
        
        overrideIndex = ApexPages.currentPage().getParameters().get('stepIndex');
        stepIndex = String.isNotBlank(overrideIndex) ? Integer.valueOf(overrideIndex) : 0; 
        //**************************************** STEP 2 **************************************** //
        //****************  set controller to Show existing Project Members ************/        
        colNames = new List<String>{'Core_IPS_Contact__r.FirstName', 'Core_IPS_Contact__r.LastName','Core_IPS_Contact__r.Email','Core_Status__c'};
            
            query = 'Select Core_IPS_Contact__c,Core_Status__c,Core_IPS_Contact__r.FirstName, Core_IPS_Contact__r.LastName, Core_IPS_Contact__r.Email, Core_IPS_Contact__r.Account.Name '+
                    ' FROM Core_IPS_Project_Member__c WHERE  Core_Status__c = \'ACTIVE\' AND  Core_IPS_Contact__r.AccountId  =\''+loggedInUserAcctId+'\'  AND Core_IPS_Project__c = \''+(ipsProject.Id == null ? '' :ipsProject.Id)+'\'';
   
      
        System.debug(IPS_PROJ_MEM+' Existing >>>- initialize ->>> Query  '+query);
        cont = new Core_CustomSetController(query, colNames, true, false, 'Core_IPS_Contact__r.Name');
        
        mTable_SetCntrlr = new Map<String, Core_CustomSetController>();
        mTable_SetCntrlr.put(EXISTING_RECORDS, cont);
        
        //**************** Current set controller to show Available contacts for adding to project Members ************/
        colNames = new List<String>{'FirstName','LastName','Email','Account.Name'};
            
           // query = 'Select LastName, FirstName,Core_Status__c, Email, Account.Name, Core_IPS_Active__c From Contact Where AccountId = \''+loggedInUserAcctId+'\' AND ID != \''+loggedInUserContId+'\'  AND Core_IPS_Active__c  = true  ';
        //query += ' AND ID NOT IN ( Select Core_IPS_Contact__c FROM Core_IPS_Project_Member__c where  Core_Status__c = \'ACTIVE\' AND Core_IPS_Project__c = \''+iipsProjectrojId+'\')';
        
         
            query = 'Select LastName, FirstName,Core_Status__c, Email, Account.Name, Core_IPS_Active__c From Contact Where AccountId = \''+loggedInUserAcctId+'\' AND ID != \''+loggedInUserContId+'\'  AND Core_IPS_Active__c  = true  ';
        query += ' AND ID NOT IN ( Select Core_IPS_Contact__c FROM Core_IPS_Project_Member__c where  Core_Status__c = \'ACTIVE\' AND Core_IPS_Project__c = \''+iipsProjectrojId+'\') And ID in (SELECT ContactId FROM User WHERE IsActive = true)';
        Map<String, Object> bindMap1 = new Map<String, Object>{
                'status' => 'ACTIVE',
                'loggedInUserAcctId' => loggedInUserAcctId,
                'loggedInUserContId'=> loggedInUserContId,
                'iipsProjectrojId' => iipsProjectrojId
            };
            query = 'Select LastName, FirstName,Core_Status__c, Email, Account.Name, Core_IPS_Active__c From Contact Where AccountId = loggedInUserAcctId  AND ID != loggedInUserContId  AND Core_IPS_Active__c  = true  ' +
                'AND ID NOT IN ( Select Core_IPS_Contact__c FROM Core_IPS_Project_Member__c where  Core_Status__c = \'ACTIVE\' AND Core_IPS_Project__c = iipsProjectrojId) And ID in (SELECT ContactId FROM User WHERE IsActive = true)';
        cont = new Core_CustomSetController(query, colNames, true, false, 'Name, email');
        
        mTable_SetCntrlr.put(AVAILABLE_RECORDS, cont);
        mStep_SetCntlr.put(IPS_PROJ_MEM, mTable_SetCntrlr);
        
        //******************** STEP 3 ******************** //
        //****************  set controller to Show existing IPS Products************/     
        colNames = new List<String>{ 'Core_Supported_Product_Name__c', 'Core_IPS_Product_Status__c' , 'Product_Application__c' };
            query = 'Select Name, Core_Supported_Product_Name__c,Core_IPS_Product_Status__c, Core_Intel_Product__c,Product_Application__c, Core_Supported_Product__c  '+
            'FROM Core_IPS_Product__c where Core_IPS_Product_Status__c = \'ACTIVE\' AND  Core_IPS_Project__c = \''+iipsProjectrojId+'\'';
        
        System.debug(IPS_PROJ_PROD+' Existing >>> Initialize >>> Query  '+query);
        cont = new Core_CustomSetController(query, colNames, true, false, 'Name,Core_Supported_Product_Name__c');
        
        mTable_SetCntrlr = new Map<String, Core_CustomSetController>();
        mTable_SetCntrlr.put(EXISTING_RECORDS, cont);
        mStep_SetCntlr.put(IPS_PROJ_PROD, mTable_SetCntrlr);
        System.debug('query----'+query);
        
        //****************  set controller to Show Available IPS Products************/     
        //Create set controller for Adding Products
        colNames = new List<String>{ 'Name' ,'Description', 'Status' };
            query = 'Select Name,Account.Name, Core_Supported_Product__r.Core_Product_Organization__r.Name, Core_Supported_Product__r.Core_Flag_Status__c, '+
            'Core_Code_Name__c,  InstallDate, Status, Description, Core_IPS_Asset__c, Core_IPS_Project__c, Core_Supported_Product__c, Core_Product_Organization__c '+
            'From Asset '+
            'Where (AccountId = \''+loggedInUserAcctId+'\' or RecordType.Name = \'Public Products\' or Core_IPS_Project__c = Null ) AND status = \'Active\' AND Core_IPS_Supported_Product_EOIS__c = false AND '+
            'Core_Supported_Product__C NOT IN ( Select Core_Supported_Product__c FROM Core_IPS_Product__c WHERE Core_IPS_Product_Status__c = \'ACTIVE\' AND Core_IPS_Project__c = \''+iipsProjectrojId+'\')';    
        
        System.debug('query----'+query);
        cont = new Core_CustomSetController(query, colNames, true, false, 'Name');
        
        mTable_SetCntrlr.put(AVAILABLE_RECORDS, cont);
        mStep_SetCntlr.put(IPS_PROJ_PROD, mTable_SetCntrlr);
        
        System.debug('  \n\n  initialize METHOD  mStep_SetCntlr    '+mStep_SetCntlr);
        //To get the URL parameters to hide/show pageblocks in Remove(Inactivate) Products/Members scenario	     
        modeStr  = ApexPages.currentPage().getParameters().get('modeStr');	
        projOwnerId = ApexPages.currentPage().getParameters().get('projOwnerId');
    }
    
    //Constructor
    public Core_ExternalUser_IPS_Project_Rem_Ctrl(ApexPages.StandardController stdCntrlr){ 
        System.debug(' Logged In User '+loggedInUser);
        ipsProject = (Core_IPS_Project__c) stdCntrlr.getRecord();
        if(ipsProject != null && String.isNotBlank(ipsProject.Id)){
            try{ 
                //ReQuery for the additional fields 
                ipsProject = [Select c.Core_MPNDA__c, c.Core_IPS_Project_ID__c, RecordTypeId, Name, Core_IPS_GroupId__c, Core_Project_Description__c, Core_Status__c 
                              From Core_IPS_Project__c c where Id =: ipsProject.Id]; 
                
            }catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
                System.debug(' Exception Occured in controller  '+e);
            }
        }else{
            ipsProject = new Core_IPS_Project__c();
        }
        
        System.debug('  \n Constructor StdController Record  '+ipsProject+' >> \n Logged in User Object '+loggedInUser);
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
            System.debug('  Constructor IPS Project  ELSE condition '+iipsProjectrojectId+' . '+String.isNotBlank(iipsProjectrojectId));
            
        }
        System.debug(ipsProject +'\n ------- Constructor END  ------ ');
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
        System.debug(' \n ----------- nextStep Invoked Current step : ------------- '+steps[stepIndex]);
        stepIndex +=1;
    }
    
    //Inserting IPS Project
    private void createIPSProject(){
        ipsProject.Core_Status__c = 'New';
        if(String.isBlank(ipsProject.Core_MPNDA__c))
            ipsProject.Core_MPNDA__c = 'N/A';
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
                ipsProject.Core_Status__c = 'Active';
                upsert ipsProject;
                //Add members to Project
                Stepindex = 1;
                upsertProjectMembers();
                //Add IPS Products to Project  
                Stepindex = 2;
                upsertIPSProducts();
                upsertAsserts();
            }
            pr = new PageReference('/'+ipsProject.Id);
        }
        catch(System.DMLException e){
            System.debug(' Exception Occured '+e);
            Stepindex = 0;
            pr =  null;
        }
        System.debug(' Returning  page '+pr);
        return pr;
    }
    
    //Method to call when Buttons Add Members/Remove Members Add Products/Remove Products
    public PageReference updateRecords(){ 
        modeStr = 'add';
        if(steps[stepIndex] == IPS_PROJ_PROD){
            upsertIPSProducts();
            upsertAsserts();
            
        }else if(steps[stepIndex] == IPS_PROJ_MEM){
            upsertProjectMembers();
        }
        
        PageReference pr = new PageReference('/'+ipsProject.Id);
        System.debug(' Returning to view page '+pr);
        return pr;
    }
    
    /** Pagination buttons for the table that shows available items for selection  **/
    public void firstPage(){
        System.debug(' ++++++++ First Button invoked'+btnActionSource);
        
        mStep_SetCntlr.get(steps[stepIndex]).get(btnActionSource).sobjectRecords = null;
        mStep_SetCntlr.get(steps[stepIndex]).get(btnActionSource).setCntrlr.first();  
    }
    public void previousPage(){
        System.debug(' ++++++++ Previous Button invoked'+btnActionSource);
        
        mStep_SetCntlr.get(steps[stepIndex]).get(btnActionSource).sobjectRecords = null;
        mStep_SetCntlr.get(steps[stepIndex]).get(btnActionSource).setCntrlr.previous();  
    }
    public void nextPage(){
        System.debug(' ++++++++ Next Button invoked'+btnActionSource);
        mStep_SetCntlr.get(steps[stepIndex]).get(btnActionSource).sobjectRecords = null;
        mStep_SetCntlr.get(steps[stepIndex]).get(btnActionSource).setCntrlr.next(); 
    }
    public void lastPage(){
        System.debug(' ++++++++ Last Button invoked'+btnActionSource);
        mStep_SetCntlr.get(steps[stepIndex]).get(btnActionSource).sobjectRecords = null;
        mStep_SetCntlr.get(steps[stepIndex]).get(btnActionSource).setCntrlr.last();     
    }
    
    public void reset(){
        System.debug('\n\n ++++++++ Reset Invoked  >>>  '+btnActionSource);
        System.debug('\n Reset Method Invoked '+mStep_SetCntlr.get(steps[stepIndex]).get(btnActionSource).setCntrlr);
        mStep_SetCntlr.get(steps[stepIndex]).get(btnActionSource).setCntrlr = null;
    }
    
    //This Method Updates records in the Selected table when records are selected/Unselected from Available records table
    public void updateSelectedRecords(){
        modeStr  = ApexPages.currentPage().getParameters().get('modeStr');	
        
        System.debug('\n\n Update Existing Method invoked '+steps[stepIndex]);
        system.debug('mStep_SetCntlr=====>'+mStep_SetCntlr);
        
        Core_CustomSetController Con = (modeStr =='remove') ? mStep_SetCntlr.get(steps[stepIndex]).get(EXISTING_RECORDS) 
            : mStep_SetCntlr.get(steps[stepIndex]).get(AVAILABLE_RECORDS) ;
        
        for(Core_CustomSetController.Wrapper w : con.sobjectRecords){ 
            if(w.selected == true){
                con.selectedRecords.put(w.sobj.Id, new Core_CustomSetController.Wrapper(w.sobj, true));
            }else if(w.selected == false && con.selectedRecords.containsKey(w.sobj.Id)){
                con.selectedRecords.remove(w.sobj.Id);
            }
        }
        System.debug(' +++++++ SELECTED RECORDS '+mStep_SetCntlr.get(steps[stepIndex]).get(AVAILABLE_RECORDS).selectedRecords);
    }
    
    
    //Insert Project Members,Activate Members
    public void upsertProjectMembers(){
        System.debug(mStep_SetCntlr.get(steps[stepIndex]).get(AVAILABLE_RECORDS)+'==\n upsertProjectMembers Invoked >>'+mStep_SetCntlr);
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
            System.debug(' >>>>>>>>>>> Selected Contact '+w);
            Core_IPS_Project_Member__c pm = new Core_IPS_Project_Member__c();
            pm.Core_IPS_Contact__c = w.sobj.Id;
            pm.Core_Selective_Member__c = true;
            pm.Core_Status__c = 'Active';
            pm.Core_User__c = mContIdUserId.get(w.sobj.id);
            pm.Core_IPS_Project__c = ipsProject.Id;
            pm.Id = mContIdips_ProjectId.get(w.sobj.Id);
            lProjMembers.add(pm);
        }
        
        System.debug(' Selected Project Members Adding>> '+lProjMembers);
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
                prod.Core_IPS_Project__c = ipsProject.Id;
            }
            prod.Core_Supported_Product__c = assetObj.Core_Supported_Product__c;
            prod.Core_IPS_Product_Status__c ='Active';
            prod.Status__c = 'Approved';
            prod.Core_IPS_IsAutoApprove__c = true;
            prod.Core_Intel_Product__c  = assetObj.Id;
            prod.Core_IsSubmitted_Header__c = true;
            if(String.isNotBlank(IPSProductBasicRecordType))
                prod.RecordTypeId  = IPSProductBasicRecordType;
            lIPSProducts.add(prod);
        }
        upsert lIPSProducts;
        if(lIPSProducts.size()!=null){
            updateAssertsStatus(lIPSProducts);
        }        
        System.debug(' >>> '+lIPSProducts);
    }
    
    //Inactivate all the selected assets
    public void upsertAsserts(){
        Core_CustomSetController sc = mStep_SetCntlr.get(steps[stepIndex]).get(EXISTING_RECORDS);
        List<SOBject> assetsToInactivate = new List<SOBject>();
        System.debug(' +++sc  >>'+sc);
        for(Core_CustomSetController.Wrapper w : sc.sobjectRecords){
            if(w.selected == true){
                w.sobj.put('Core_IPS_Product_Status__c', 'InActive');
                assetsToInactivate.add(w.sobj);
            }
        }
        System.debug('\n Inactive existing products List  >>'+assetsToInactivate);
        update assetsToInactivate;
    } 
    
    //Updating the Intel Product Status when Upserting IPS Products
    public void updateAssertsStatus(List<Core_IPS_Product__c> lIPSProducts){
        List <Asset> lAssetsToActivate = new List<Asset>();   
        
        for(Integer a = 0; a <lIPSProducts.size(); a++){
            //Query Supported Product from IPS Product 
            Core_IPS_Product__c ipsProd = [Select Name,Id,Core_Supported_Product__R.Id,Core_Intel_Product__C
                                           from Core_IPS_Product__c where id =:lIPSProducts.get(a).Id limit 1];
            //Query Asset 
            Asset assetActivate = [Select id,Status,UsageEndDate from Asset where Core_Supported_Product__R.id =:ipsProd.Core_Supported_Product__R.Id 
                                   and Core_IPS_Project__R.id =:ipsProject.Id limit 1];
            System.debug('ZAPP'+assetActivate);
            assetActivate.Status = 'Active';
            lAssetsToActivate.add(assetActivate);
        }
        system.debug('Final list of Assets to activate '+ lAssetsToActivate);
        upsert lAssetsToActivate;
    }
    
    //Method to remove Members
    public PageReference removeMembers(){
        PageReference pr;
        string  projOwnerName;
        projOwnerId = ApexPages.currentPage().getParameters().get('projOwnerId');
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
        
        System.debug(' Selected Project Members Deleting>> '+sContIds);
        List<Core_IPS_Project_Member__c> lstInactivate = [Select Id,Core_IPS_Project__R.Id,Core_User__R.Id,Core_Status__c,Core_User__R.Name FROM Core_IPS_Project_Member__c where ID IN : sContIds ];
        System.debug(' Selected Project Members Objects >> '+lstInactivate);
        
        for(Core_IPS_Project_Member__c p : lstInactivate){
            if(projOwnerId == p.Core_User__c){		
                projOwnerName =p.Core_User__R.Name ;
            }else{
                p.Core_Status__c = 'InActive';
            }
        }
        If(String.isNotBlank(projOwnerName)){
            modeStr = 'remove';
            pr = null;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'You cannot remove the owner of a project: '+projOwnerName+' .<br/> If you would like to remove this user from this project, please contact your Intel Representative to change the owner to a different user.'));		
        }
        else{
            update lstInactivate;
            pr = new PageReference('/'+ipsProject.Id); 
        }
        return pr;
    }
}