public  class Core_ExternalUser_IPS_Project_Contlr_Dup {
    public Core_IPS_Project__c ipsProject{get;set;}
    public static final String IPS_PROJ = 'Premier Support Project';
    public static final String IPS_PROJ_MEM = 'Premier Support Project Members';
    public static final String IPS_PROJ_PROD = 'Premier Support Project Products';
    
    
    private transient List<String>  colNames = null;
    private List<String> contactColName = new List<String>();
    private String loggedInUserAcctId = null;
    private String loggedInUserContId = null;
    private String query = null;
    private Account loggedinUsrAcct = null;
    
    public List<String> steps {get;set;}
    public Integer stepIndex {get;set;}
    public Map<String, CustomSetController> mStepSetcntrlr{get;set;}
    public User loggedInUser = [Select Id, Name,   ContactId, Contact.AccountId From User where Id =: UserInfo.getUserId()];
    public User getLoggerInUser(){ return loggedInUser;}
      
    //public Map<Id, Core_IPS_Project_Member__c> mExtingProjMemb {get;set;}
    //public Map<Id, Core_IPS_Product__c > mExtingProducts {get;set;}
    
    public Map<String, CustomSetController> mExistingSelection {get;set;}
    
    public String IPSProductBasicRecordType{ get{
        if(IPSProductBasicRecordType == null){
            try{
             IPSProductBasicRecordType = [SELECT Id FROM RecordType where SobjectType = 'Core_IPS_Product__c' AND DeveloperName = 'Core_IPS_Project_Product'].Id;   
            }catch(Exception e){ 
                IPSProductBasicRecordType = '';
            }
        }
        return IPSProductBasicRecordType;
    } private set;}
    
    
    public void initialize(){
        loggedInUserAcctId = loggedInUser.Contact.AccountId;
        loggedInUserContId = loggedInUser.ContactId ;
        String iipsProjectrojId = (ipsProject.Id == null ? '' : ipsProject.Id);
        System.debug('  \n initialize METHOD  IipsProjectroject object : '+ipsProject);
        
        mStepSetcntrlr = new Map<String, CustomSetController>();
        mExistingSelection = new Map<String, CustomSetController>();
        
        CustomSetController cont = null;
        
        //**************************************************************/
        //**************** Current set controller to show Available List ************/
        //**************************************************************/
        //Create set controller for Adding Project Members        
        colNames = new List<String>{'FirstName','LastName','Email','Account.Name'};
            query = 'Select LastName, FirstName, Email, Account.Name From Contact Where AccountId = \''+loggedInUserAcctId+'\' AND ID != \''+loggedInUserContId+'\'  AND Core_IPS_Active__c  = true  ';
            query += ' AND ID NOT IN ( Select Core_IPS_Contact__c FROM Core_IPS_Project_Member__c where  Core_Status__c = \'ACTIVE\' AND Core_IPS_Project__c = \''+iipsProjectrojId+'\' )';
        cont = new CustomSetController(query, colNames, false, false, 'Name, email');
        mStepSetcntrlr.put(IPS_PROJ_MEM, cont);
        
        //Create set controller for Adding Products
        query = 'Select Name, Core_Supported_Product__r.Core_Product_Organization__r.Name, Core_Supported_Product__r.Core_Flag_Status__c, '+
            'Core_Code_Name__c,  InstallDate, Status, Description, Core_IPS_Asset__c, Core_IPS_Project__c, Core_Supported_Product__c, Core_Product_Organization__c '+
            'From Asset '+
            'Where AccountId = \''+loggedInUserAcctId+'\' AND status = \'Active\'  AND '+
            'Core_Supported_Product__C NOT IN ( Select Core_Supported_Product__c FROM Core_IPS_Product__c WHERE Core_IPS_Product_Status__c = \'ACTIVE\' AND Core_IPS_Project__c = \''+iipsProjectrojId+'\'  )';
        colNames = new List<String>{ 'Name' , 'Core_Supported_Product__r.Core_Product_Organization__r.Name' , 'Core_Supported_Product__r.Core_Flag_Status__c' };
            
            
            cont = new CustomSetController(query, colNames, true, false, 'Name');
        mStepSetcntrlr.put(IPS_PROJ_PROD, cont);
        
        String ind = ApexPages.currentPage().getParameters().get('stepIndex');
        stepIndex = String.isNotBlank(ind) ? Integer.valueOf(ind) : 0; 
        
        //**************************************************************/
        //****************  set controller to Show existing ************/
        //**************************************************************/
        // Create set controller for Existing Project Members */   
        colNames = new List<String>{'Core_IPS_Contact__r.FirstName', 'Core_IPS_Contact__r.LastName','Core_IPS_Contact__r.Email','Core_IPS_Contact__r.Account.Name' };
            query = 'Select Core_IPS_Contact__c, Core_IPS_Contact__r.FirstName, Core_IPS_Contact__r.LastName, Core_IPS_Contact__r.Email, Core_IPS_Contact__r.Account.Name FROM Core_IPS_Project_Member__c where  Core_Status__c = \'ACTIVE\' AND Core_IPS_Contact__c !=\''+loggedInUserContId+'\' AND Core_IPS_Project__c = \''+(ipsProject.Id == null ? '' :ipsProject.Id)+'\'';
        System.debug(IPS_PROJ_MEM+' Existing >>>- initialize ->>> Query  '+query);
        cont = new CustomSetController(query, colNames, false, true, 'Core_IPS_Contact__r.Name');
        mExistingSelection.put(IPS_PROJ_MEM, cont);

 
    // Create set controller for Existing IPS Products*/           
        colNames = new List<String>{'Name', 'Core_Supported_Product_Name__c', 'Core_Intel_Product_Status__c',  'Core_IPS_Product_Status__c' };
        query = 'Select Name, Core_Supported_Product_Name__c, Core_Intel_Product_Status__c,  Core_IPS_Product_Status__c, Core_Intel_Product__c, Core_Supported_Product__c  '+
                'FROM Core_IPS_Product__c where Core_IPS_Product_Status__c = \'ACTIVE\' AND  Core_IPS_Project__c = \''+iipsProjectrojId+'\'';
        System.debug(IPS_PROJ_PROD+' Existing >>> Initialize >>> Query  '+query);
        cont = new CustomSetController(query, colNames, false, true, 'Name');
        mExistingSelection.put(IPS_PROJ_PROD, cont);
        
        System.debug('  \n\n  initialize METHOD  mExistingSelection '+mExistingSelection);
        System.debug('  \n\n  initialize METHOD  mStepSetcntrlr    '+mStepSetcntrlr);
    }
    
    //Constructor
    public Core_ExternalUser_IPS_Project_Contlr_Dup(){
        initialize();
    }
    public ApexPages.StandardController stdCntrlr =null;
    //Constructor
    public Core_ExternalUser_IPS_Project_Contlr_Dup(ApexPages.StandardController stdCntrlr){
        this.stdCntrlr =stdCntrlr;
        System.debug(' Logged In User '+loggedInUser);
        ipsProject = (Core_IPS_Project__c) stdCntrlr.getRecord();
        
        if(ipsProject != null && String.isNotBlank(ipsProject.Id)){
            try{
                //ReQuery for the additional fields
                ipsProject = [Select c.Core_MPNDA__c, c.Core_IPS_Project_ID__c, RecordTypeId, Name, Core_IPS_GroupId__c, Core_Project_Description__c, Core_Status__c 
                       From Core_IPS_Project__c c where Id =: ipsProject.Id]; 
                
                /*ipsProject = [Select c.Core_MPNDA__c, c.Core_IPS_Project_ID__c, RecordTypeId, Name, Core_IPS_GroupId__c, Core_Project_Description__c, 
                       (Select Core_IPS_Project__c, Core_IPS_Contact_Account__c, Core_IPS_Contact__c, Core_Selective_Member__c, 
                        Core_Status__c, Core_User__c 
                        From Project_Members__r),
                       (Select Name, RecordTypeId, Core_IPS_Project__c, Core_IPS_Prodcut_Org__c, Core_IPS_Product_Status__c,
                        Core_Supported_Product__c, Status__c, Core_Intel_Product__c  
                        From IPS_Products__r) 
                       From Core_IPS_Project__c c where Id =: ipsProject.Id];
                
                for( Core_IPS_Project_Member__c pm : ipsProject.Project_Members__r)
                    mExtingProjMemb.put(pm.Core_IPS_Contact__c, pm);
                for( Core_IPS_Product__c prd : ipsProject.IPS_Products__r)
                    mExtingProducts.put(prd.Core_Supported_Product__c, prd); */
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
        
        if(loggedInUser.Contact.AccountId == null)
          loggedInUser = [Select Id, Name,   ContactId, Contact.AccountId From User where Id ='0053F000000HuWIQA0'];
        
        if(loggedInUser.Contact.AccountId == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid community user or user not authorized '));
            
            //Note - 
            String uid = ApexPages.currentPage().getParameters().get('uid'); //Revisit the line
            if(String.isNotBlank(uid)){
                loggedInUser = [Select Id, Name,   ContactId, Contact.AccountId From User where Id =: uid];
                initialize();
            }
        }
        else{
            
            initialize();
            
            //Read Values from URL Paramters
            String ind = ApexPages.currentPage().getParameters().get('stepIndex');
            String iipsProjectrojectId = ApexPages.currentPage().getParameters().get('Core_IPS_Project__c'); //Revisit the line
            stepIndex = String.isNotBlank(ind) ? Integer.valueOf(ind) : 0;
            System.debug('  Constructor IPS Project  ELSE condition '+iipsProjectrojectId+' . '+String.isNotBlank(iipsProjectrojectId));
            
        }
        System.debug(ipsProject +'\n ------- Constructor END  ------ ');
        
    }
    
    public Boolean getRenderExistingRecordsTable(){
        System.debug(' \n getRenderExistingRecordsTable '+steps[stepIndex]);
        return ( mExistingSelection != null && mExistingSelection.get(steps[stepIndex]) != null );
    }
    
    public PageReference previousStep(){ 
        stepIndex = stepIndex-1;
        stepIndex = stepIndex < 0 ? 0: stepIndex;
        return null;
    }
    
    public void nextStep(){ 
        System.debug(' \n ----------- nextStep Invoked Current step : ------------- '+steps[stepIndex]);
        try{
            if(steps[stepIndex] == IPS_PROJ){
                saveIPSProject();
            }else if(steps[stepIndex] == IPS_PROJ_MEM){
                upsertProjectMembers();
                mStepSetcntrlr.get(IPS_PROJ_MEM).sobjectRecords = null;
            }
            stepIndex +=1;
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            System.debug(' Exception Occured '+e);
        }
        System.debug(' Next Step > '+steps[stepIndex]+' \n');
    }

    private void saveIPSProject(){
           // ipsProject.Core_Status__c = 'Active';
            if(String.isBlank(ipsProject.Core_MPNDA__c))
                ipsProject.Core_MPNDA__c = 'N/A';
            upsert ipsProject;
            Map<Id, Core_IPS_Project__c> mipsProject = new Map<Id, Core_IPS_Project__c>();
            mipsProject.put(ipsProject.id, ipsProject);
            Core_ExternalUser_IPS_Project_Helper.createAccountOnProjectCreationForExternalCustomer(mipsProject, loggedInUser);
        
    }
    
    public PageReference saveAll(){
        upsertIPSProducts();
           core_ips_project_controller con=new core_ips_project_controller(stdCntrlr);
           con.changeStatusToSubmitted();
        PageReference pr = new PageReference('/'+ipsProject.Id);
        System.debug(' Returning to view page '+pr);
        return pr;
    }
    
    public void firstPage(){
        mStepSetcntrlr.get(steps[stepIndex]).sobjectRecords = null;//new List<CustomSetController.Wrapper>();
        mStepSetcntrlr.get(steps[stepIndex]).setCntrlr.first();
    }
    public void previousPage(){
        mStepSetcntrlr.get(steps[stepIndex]).sobjectRecords = null;//new List<CustomSetController.Wrapper>();
        mStepSetcntrlr.get(steps[stepIndex]).setCntrlr.previous();               
    }
    public void nextPage(){
        System.debug(' Main CONTROLLER Next page action invoked ');
        mStepSetcntrlr.get(steps[stepIndex]).sobjectRecords = null;//new List<CustomSetController.Wrapper>();
        mStepSetcntrlr.get(steps[stepIndex]).setCntrlr.next();       
    }
    public void lastPage(){
        mStepSetcntrlr.get(steps[stepIndex]).sobjectRecords = null;//new List<CustomSetController.Wrapper>();
        mStepSetcntrlr.get(steps[stepIndex]).setCntrlr.last();       
    }
    
    public void reset(){
        System.debug('\n\n Reset Method Invoked '+mStepSetcntrlr.get(steps[stepIndex]).setCntrlr);
        mStepSetcntrlr.get(steps[stepIndex]).setCntrlr = null;
        System.debug(' Reset Method Invoked '+mStepSetcntrlr.get(steps[stepIndex]).setCntrlr+' \n\n ');
        
    }

    //TODO make this generic    
    public void resetExisting(){
        System.debug('\n\n resetExisting Method Invoked '+mStepSetcntrlr.get(steps[stepIndex]).setCntrlr);
        mExistingSelection.get(steps[stepIndex]).setCntrlr = null;
        System.debug(' resetExisting Invoked '+mExistingSelection.get(steps[stepIndex]).setCntrlr+' \n\n ');
        
    }

    
    public void updateExisting(){
        System.debug('\n\n Update Existing Method invoked '+steps[stepIndex]);
        List<CustomSetController.Wrapper> wl = mStepSetcntrlr.get(steps[stepIndex]).sobjectRecords;
        CustomSetController con = mStepSetcntrlr.get(steps[stepIndex]);
        List<CustomSetController.Wrapper> wlNew = mStepSetcntrlr.get(steps[stepIndex]).sobjectRecords;
        for(CustomSetController.Wrapper w : wl){ 
            if(w.selected == true){
                //SObject sobj = Schema.getGlobalDescribe().get('Contact').newSObject();
                //sobj.put('Id', w.sobj.Id);
                //sobj.put('FirstName', w.sobj.get('FirstName'));
                //sobj.put('LastName', w.sobj.get('LastName'));*/
                con.selectedRecords.put(w.sobj.Id, new CustomSetController.Wrapper(w.sobj, true));
            }else if(w.selected == false && con.selectedRecords.containsKey(w.sobj.Id)){
                con.selectedRecords.remove(w.sobj.Id);
            }
        }
        System.debug(' +++++++ SELECTED RECORDS '+mStepSetcntrlr.get(steps[stepIndex]).selectedRecords);
    }
    
    
    public List<CustomSetController.Wrapper> getExistingSObjectRecords(){
        CustomSetController cs = mExistingSelection.get(steps[stepIndex]);
        System.debug(' \n\n\n\n\n cs.sobjectRecords '+cs.sobjectRecords);
        return cs.sobjectRecords;
    }
    
    public void upsertProjectMembers(){
        System.debug('\n upsertProjectMembers Invoked >>');
        List<Core_IPS_Project_Member__c> lUpsertProjMemb = new List<Core_IPS_Project_Member__c>();
        Set<Id> sContIds = new Set<ID>();
        CustomSetController sc = mStepSetcntrlr.get(steps[stepIndex]);
        Map<Id, Id> mContIdipsProjectId = Core_ExternalUser_IPS_Project_Helper.getExistingMembers(ipsProject.Id);
        for(CustomSetController.Wrapper w: sc.getAllSelectedRecords()){
            sContIds.add(w.sobj.Id);
        }
        
        //Retrieve User Records
        Map<Id, Id> mContIdUserId = Core_ExternalUser_IPS_Project_Helper.getContactUserRecordIds(sContIds);
        
        
        for(CustomSetController.Wrapper w: sc.getAllSelectedRecords()){
            System.debug(' >>>>>>>>>>> Selected Contact '+w);
            Core_IPS_Project_Member__c pm = new Core_IPS_Project_Member__c();
            pm.Core_IPS_Contact__c = w.sobj.Id;
            pm.Core_Selective_Member__c = true;
            pm.Core_Status__c = 'Active';
            pm.Core_User__c = mContIdUserId.get(w.sobj.id);
            pm.Core_IPS_Project__c = ipsProject.Id;
            // pm.Core_External_Id__c = String.ValueOf(ipsProject.Id)+String.ValueOf(w.sobj.id);
            pm.Id = mContIdipsProjectId.get(w.sobj.Id);
            lUpsertProjMemb.add(pm);
        }
        
        System.debug(' Selected Project Members Adding>> '+lUpsertProjMemb);
        upsert lUpsertProjMemb;
        //Database.upsert(lUpsertProjMemb, Core_IPS_Project_Member__c.Fields.Core_External_Id__c);
        
        
        sc = mExistingSelection.get(steps[stepIndex]);
        sContIds = new Set<ID>();
        for(CustomSetController.Wrapper w: sc.sobjectRecords){
            if(w.selected == false)
                sContIds.add(w.sobj.Id);
            
        }
        //TODO: IMPORTNANT : Handler if existing records were unselected and selected in the sames seession while renavitaing pages
        //
        System.debug(' Selected Project Members Deleting>> '+sContIds);
        List<Core_IPS_Project_Member__c> lstInactivate = [Select Id, Core_Status__c FROM Core_IPS_Project_Member__c where ID IN : sContIds ];
        System.debug(' Selected Project Members Objects >> '+lstInactivate);
        for(Core_IPS_Project_Member__c p : lstInactivate){
            p.Core_Status__c = 'InActive';
        }
        update lstInactivate;
        
    }
    
    public void upsertIPSProducts(){
        System.debug('\n upsertIipsProjectroducts Invoked >>');
        
        List<Core_IPS_Product__c> lIPSProducts = new List<Core_IPS_Product__c>();
        List<SOBject> lInactiveProd = new List<SOBject>();
        Set<Id> sSuppProdIds = new Set<ID>();
        List<Asset> lAssets = new List<Asset>();
        
        CustomSetController sc = mStepSetcntrlr.get(steps[stepIndex]);
        
        //Query if Any selected assets existed as InActive
        Map<Id, Asset> existingAssets =  Core_ExternalUser_IPS_Project_Helper.getExistingAssets(ipsProject.Id);

        System.debug(' upsertIPSProducts >> sc  >>'+sc);
        System.debug(' upsertIPSProducts >> existingAssets '+existingAssets);

        for(CustomSetController.Wrapper w: sc.getAllSelectedRecords()){
            Asset assetObj = (Asset)w.sobj;
            System.debug(' assetObj '+assetObj);
            if(existingAssets.containsKey(assetObj.Core_Supported_Product__c)){
                assetObj = existingAssets.get(assetObj.Core_Supported_Product__c);
                assetObj.Core_Project_Asset_Status__c = 'Active';
                assetObj.status = 'Active';
                assetObj.UsageEndDate = null;
                lAssets.add(assetObj);
            }else{
                assetObj.Id = null;
                assetObj.Core_IPS_Project__c = ipsProject.Id;
                assetObj.Core_Project_Asset_Status__c = 'Active';
                assetObj.status = 'Active';
                lAssets.add(assetObj);
            }
        }
        upsert lAssets;
        
        //
        
        Map<Id, Core_IPS_Product__c> mSuppProd_ipsProd = Core_ExternalUser_IPS_Project_Helper.getAllInActiveIPSProducts(ipsProject.Id);
        
        for(Asset a: lAssets){
            System.debug(' Asset after inserting >>'+a );
            Core_IPS_Product__c prod =  mSuppProd_ipsProd.get(a.Core_Supported_Product__c);
            if(prod == null){
                prod = new Core_IPS_Product__c();
                prod.Core_IPS_Project__c = ipsProject.Id;
                prod.Core_Supported_Product__c = a.Core_Supported_Product__c;
                prod.Core_IPS_Product_Status__c ='Active';
                prod.Status__c = 'Approved';
                prod.Core_Intel_Product__c  = a.Id;
                if(String.isNotBlank(IPSProductBasicRecordType))
                  prod.RecordTypeId  = IPSProductBasicRecordType;
            }else{
                prod.Core_IPS_Product_Status__c ='Active';
                //TODO Active the Asset
            }
               
            
            
            lIPSProducts.add(prod); 
        }
        
        /*for(CustomSetController.Wrapper w : sc.getAllSelectedRecords()){
            System.debug(' IPS Products pw.selected  >>'+w );
            Core_IPS_Product__c prod = new Core_IPS_Product__c();
            prod.Core_IPS_Project__c = ipsProject.Id;
            prod.Core_IPS_Product_Status__c = 'Active';
            Asset assetObj = (Asset)w.sobj;
            prod.Core_Supported_Product__c = assetObj.Core_Supported_Product__c;
            prod.Core_IPS_Product_Status__c ='Active';
            lIPSProducts.add(prod); 
        }*/
        
        System.debug('\n Inserting New Products List  >>'+lIPSProducts);
        if(!lIPSProducts.isEmpty())
            upsert lIPSProducts;
        //TODO merge to single statement
        sc = mExistingSelection.get(steps[stepIndex]);
        System.debug(' +++sc  >>'+sc);
        for(CustomSetController.Wrapper w : sc.sobjectRecords){
            if(w.selected == false){
                w.sobj.put('Core_IPS_Product_Status__c', 'InActive');
                //s.sobj.put('UsageEndDate', System.today());
                //TODO usage end date
                lInactiveProd.add(w.sobj);
            }
        }
        System.debug('\n Inactive existsing products List  >>'+lInactiveProd);
        update lInactiveProd;
        
    }

    
}