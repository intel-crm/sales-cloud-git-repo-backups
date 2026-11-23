/**************************************************************************************************
Apex Class Name :  Core_IPS_AddDefaultCaseOwnerController
Description     :  Adding and viewing Default case owner for a premier support project product
Modification Log :
* Developer                         Date                   Description
* ----------------------------------------------------------------------------                 
* Sumukh                          13/01/2020                 Created
*****************************************************************************************************/

Public with sharing class Core_IPS_AddDefault_CaseOwner_Controller{   
       
    private static final String DEFAULT_SORT_FIELD = 'FirstName ';
    public Id productId = ApexPages.currentPage().getParameters().get('productId');
    public Id projectId ;
    public List<User> userList{get;set;}
    public list<Group> queuelist{get;set;}
    public Core_IPS_Product__c prodObj;
    public String profileIds = System.Label.Core_IPS_DefaultCaseOwner_Profile_Id;
    public List<String> lstProfId; 
    public String partnerProfileID = System.Label.Core_IPS_Agent_Partner_Profile_id;
    public Boolean searchMadeInt{get;set;}
    public Boolean showErrorMsg{get;set;}
    public String searchText{get;set;}
    public String selectDCOoption{get;set;}
    public Boolean userToBecreated{get;set;}
    public Boolean queueToBeCreated{get;set;}
    public Boolean isSelected{get;set;}
    public Boolean isSelectedUser{get;set;}
    public Boolean isSelectedQueue{get;set;}
    public String selectedUser{get;set;}
    public String selectedUserName{get;set;}
    public String selectedQueue{get;set;}
    public String selectedQueueName{get;set;}
    private Set<Id> toBeDeletedrec;
    public Boolean isDefaultCaseOwnerPresent{get;set;}
    public String defaultCaseOwnerUserFname{get;set;}
    public String defaultCaseOwnerUserLname{get;set;}
    public String defaultCaseOwnerUserEmail{get;set;}
    public Boolean isDefaultCaseOwnerUser{get;set;}
    public String defaultCaseOwnerQueueName{get;set;}
    public String defaultCaseOwnerQueueDevName{get;set;}
    public Boolean isDefaultCaseOwnerQueue{get;set;}
    
    public Core_SortedGrid_ColumnHeader sortHeader 
    {
        get 
        {
            if(sortHeader == NULL){
                sortHeader = new Core_SortedGrid_ColumnHeader(DEFAULT_SORT_FIELD);        
            }    
            return sortHeader;                
        }        
        set
        {
            sortHeader = value;       
        }
    }    
    
    
    public Core_IPS_AddDefault_CaseOwner_Controller() {
        try{
            List<Profile> profileLst = new List<Profile>();     
            UserList = new List<User>();
            Queuelist =new List<Group>();
            searchMadeInt = false;
            showErrorMsg = false;
            isSelected = false;
            userToBecreated = false;
            queueToBeCreated= false;
            lstProfId = ProfileIds.split(';');
            isSelectedUser = false;
            isSelectedQueue = false;
            isDefaultCaseOwnerPresent = false;
            isDefaultCaseOwnerUser = false ;
            isDefaultCaseOwnerQueue = false ;
            
            if(productId != null){ 
                ProdObj = [Select id,Core_IPS_Product_Name__c,Status__c ,Core_Supported_Product__c,Core_IPS_Project__c,Core_IPS_Prodcut_Org__c, Core_IPS_Prod_Def_Case_Owner_ID__c, Core_IPS_Prod_Default_Case_Owner__c  FROM Core_IPS_Product__c where ID =:ProductId ];
                
                if(String.isNotBlank(ProdObj.Core_IPS_Prod_Def_Case_Owner_ID__c) && String.isNotBlank(ProdObj.Core_IPS_Prod_Default_Case_Owner__c)) {
                    isDefaultCaseOwnerPresent = true;
                    if(ProdObj.Core_IPS_Prod_Def_Case_Owner_ID__c.startsWith('005')) {                        
                        User usr = [Select Id, FirstName, LastName, Email FROM User WHERE Id =: ProdObj.Core_IPS_Prod_Def_Case_Owner_ID__c];
                        defaultCaseOwnerUserFname = usr.FirstName;
                        defaultCaseOwnerUserLname = usr.LastName;
                        defaultCaseOwnerUserEmail = usr.Email;
                        isDefaultCaseOwnerUser = true ;                       
                    } else {
                        Group defaultCaseOwnerQueue = [Select Id, Name, DeveloperName FROM Group WHERE Id =: ProdObj.Core_IPS_Prod_Def_Case_Owner_ID__c];
                        defaultCaseOwnerQueueName = defaultCaseOwnerQueue.Name;
                        defaultCaseOwnerQueueDevName = defaultCaseOwnerQueue.DeveloperName;
                        isDefaultCaseOwnerQueue = true ;
                    }
                }
                ProjectId = ProdObj.Core_IPS_Project__c;
            }
        }
        catch (exception ex){            
            System.debug('-- Exception Occured :'+ex.getMessage());
            System.debug('Error at line ' + ex.getStackTraceString());
        }
    }
    
    public void init() {
        isDefaultCaseOwnerPresent = false;
            isDefaultCaseOwnerUser = false ;
            isDefaultCaseOwnerQueue = false ;
                     
    }
    
    
    public Void doSearch(){
        String searchableString = '';
        UserList.clear();
        Queuelist.clear();    
        if(String.IsBlank(searchText))
        {       
            showErrorMsg = true;
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,''+'Please enter text to be searched.'));                
        }
        else if( selectDCOoption == 'User' && String.isNotEmpty(searchText)){         
            searchableString = '%'+ searchText + '%';        //Starts with search functionality
            searchableString = string.escapeSingleQuotes(searchableString);
            String sQuery;         
            sQuery = 'SELECT Id, Name, FirstName, LastName, Email FROM User ' + 
                'WHERE (ProfileID IN :lstProfId AND (FirstName like :searchableString OR LastName like ' +
                ':searchableString OR Email like :searchableString) AND (IsActive = true)) ' + 
                'ORDER BY ' + sortHeader.sortExpression + ' ' + sortHeader.sortDirection + 
                ' ' + sortHeader.sortNullFirstLast + ' Limit  1000 ' ;
            UserList = Database.query(sQuery);          
        }
        else if ( selectDCOoption =='Partner User' && String.isNotEmpty(searchText)){         
            searchableString = '%'+ searchText + '%' ;       //Starts with search functionality       
            searchableString = string.escapeSingleQuotes(searchableString);

            String sQuery;                 
            sQuery = 'SELECT Id, Name, FirstName, LastName, Email FROM User ' + 
                ' WHERE Id IN (Select Core_User__c from Core_IPS_Project_Member__c ' +
                ' where Core_IPS_Project__c =: ProjectId ) AND  (ProfileID  =: PartnerProfileID ) ' +
                ' AND (FirstName like :searchableString OR LastName like :searchableString OR ' +
                ' Email like :searchableString) AND (IsActive = true) ' +  
                ' ORDER BY ' + sortHeader.sortExpression + ' ' + sortHeader.sortDirection + 
                ' ' + sortHeader.sortNullFirstLast + ' Limit 1000 ';                    
            UserList =  Database.query(sQuery);                             
        }
        else if( selectDCOoption =='Queue' && String.isNotEmpty(searchText)){         
            searchableString = '%' + searchText + '%';      //Starts with search functionality   
            searchableString = string.escapeSingleQuotes(searchableString);
            
            String sQuery;
            sQuery = 'SELECT Id,NAME,DeveloperNAME FROM Group ' +
                ' WHERE Type =\'Queue\' ' +
                ' AND ( NAME like :searchableString OR DeveloperNAME like :searchableString ) ' +                   
                ' Limit 1000 ';
            Queuelist = Database.query(sQuery);             
        }
        
        if(UserList!=null && UserList.size() > 0 || Queuelist !=null && Queuelist.size() >0 ){
            for(User userRec: UserList){                       
                searchMadeInt = true;
                userToBecreated =true;
                //isSelected = true;            
            }
            for(Group queueRec : Queuelist){
                searchMadeInt = true;
                queueToBeCreated = true;
                //isSelected = true;
            }        
        }
        else {            
            showErrorMsg = true; 
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,''+'No User Found.'));
        }
    }
    
    
    public PageReference finished(){
        return (new PageReference ('/' + ProductId ));
    }
    
    
    public PageReference addSelectedUsers(){
        try{
            list<Core_IPS_Product__c> projProdList = new list<Core_IPS_Product__c>();       
            if(UserList.size()>0){
                for(User iPSUser : UserList){
                    Core_IPS_Product__c prodObj = new Core_IPS_Product__c();
                    prodObj.Core_IPS_Prod_Default_Case_Owner__c = iPSUser.Name;
                    prodObj.Core_IPS_Prod_Def_Case_Owner_ID__c = iPSUser.id;
                    projProdList.add(prodObj);
                } 
            }
            else if(Queuelist.size()>0){         
                for(Group iPSqueue : Queuelist){
                    Core_IPS_Product__c projProduct = new Core_IPS_Product__c();
                    projProduct.Core_IPS_Prod_Default_Case_Owner__c = IPSqueue.DeveloperNAME;
                    projProduct.Core_IPS_Prod_Def_Case_Owner_ID__c = IPSqueue.id;
                    projProdList.add(projProduct);
                } 
            }
            if(projProdList.size() > 0){
                doSearch();
                ApexPages.getMessages().clear();
                if(ApexPages.getMessages().size()>0) {
                    showErrorMsg = false;
                }    
            }           
        }     
        catch(Exception ex){
            System.debug('-- Exception Occured :'+ex.getMessage());
            System.debug('Error at line ' + ex.getStackTraceString());
        }
        return null;
    }
    
    
    public PageReference saveAndRedirect(){
        List<Core_IPS_Product__c > userToBeCreated = new List<Core_IPS_Product__c>();   
        PageReference ref = null;
        String usrQuery;
        usrQuery= 'Select id, Name, email from from User where id =: selectedUser';
        String queQuery;
        queQuery = ' Select id,Name from Group where id =: selectedQueue';
        system.debug('UserList'+UserList);
        system.debug('Queuelist'+Queuelist);
        try{
            if(UserList!= null && !UserList.isEmpty()){                   
                if(isSelected == true){                        
                    Core_IPS_Product__c projProduct = new Core_IPS_Product__c();           
                    projProduct.id = ProductId;    
                    projProduct.Core_IPS_Prod_Default_Case_Owner__c = selectedUserName;
                    projProduct.Core_IPS_Prod_Def_Case_Owner_ID__c = selectedUser;       
                    userToBeCreated.add(projProduct);          
                }       
            }
            else if(Queuelist!= null && !Queuelist.isEmpty()){      
                if(isSelected==true){
                    Core_IPS_Product__c projProd = new Core_IPS_Product__c();
                    projProd.id = ProductId;
                    projProd.Core_IPS_Prod_Default_Case_Owner__c = selectedQueueName; 
                    projProd.Core_IPS_Prod_Def_Case_Owner_ID__c = selectedQueue;          
                    userToBeCreated.add(projProd);         
                }               
            }       
            if(!userToBeCreated.isEmpty()){
                update userToBeCreated;          
            }
            ref= new PageReference('/'+ProductId);
        }
        catch(Exception e){
            showErrorMsg = true;
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error :'+e.getMessage()));           
        }
        return ref;
    }
    
    public void removeDefaultCaseOwner() {
        selectedUser = '';
        selectedUserName = '';
        selectedQueue = '';
        selectedQueueName = '';
        isDefaultCaseOwnerUser = false ;
        isDefaultCaseOwnerQueue = false ;
        isSelected = true;
        //PageReference ref = null;
        ProdObj.Core_IPS_Prod_Def_Case_Owner_ID__c = '';
        ProdObj.Core_IPS_Prod_Default_Case_Owner__c = '';
        update ProdObj;
        //init();
        //ref= new PageReference('/'+ProductId);
        //return ref;
    }
    public void refreshSelected() { 
        system.debug('refreshSelected ');
    }
    
}