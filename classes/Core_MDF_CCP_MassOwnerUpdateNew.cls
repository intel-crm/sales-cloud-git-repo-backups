public with sharing class Core_MDF_CCP_MassOwnerUpdateNew {
    //method to retrive app values
    @AuraEnabled(cacheable=true)
    public static MassOwnerMdtWrapper getAppValues()
    {
        Map<String, String> applicationMap= new Map<String, String>();
        Map<String, String> programMap = new Map<String, String>();
        Map<String, String> objectMap = new Map<String, String>();
        Map<String,String> filterFieldMap = new Map<String,String>();
        List<Core_MDF_Custom_Utility_Config__c> mdtList =new List<Core_MDF_Custom_Utility_Config__c>();
        List<Core_MDF_Custom_Utility_Config__c> finalMdtList = new List<Core_MDF_Custom_Utility_Config__c>();
        List<DropDownWrapper> applicationDropdownOptions = new List<DropDownWrapper>();
        List<DropDownWrapper> programDropdownOptions = new List<DropDownWrapper>();
        List<DropDownWrapper> objectDropdownOptions = new List<DropDownWrapper>();
        List<DropDownWrapper> fieldDropdownOptions = new List<DropDownWrapper>();
        MassOwnerMdtWrapper massOwnerWrapper = new MassOwnerMdtWrapper();
        filterCriteriaWrapper fltCriteriaWrapper = new filterCriteriaWrapper();
        
        
        try {
            mdtList = [select Core_MDF_App__c, Core_MDF_Program__c, Core_MDF_Object__c, Core_MDF_Object_Label__c, Core_MDF_Filter_Criteria__c,Core_MDF_Int_Permision_Set_Name__c, Core_MDF_Ext_Permission_Set_Name__c, Core_MDF_System_User_Name__c, Core_MDF_isProgramApplicable__c from Core_MDF_Custom_Utility_Config__c order by Core_MDF_App__c];
            if(!mdtList.isEmpty()) {
                for(Core_MDF_Custom_Utility_Config__c mdt: mdtList) {
                    finalMdtList.add(mdt);
                    if(!applicationMap.containsKey(mdt.Core_MDF_App__c)) {
                        applicationMap.put(mdt.Core_MDF_App__c, mdt.Core_MDF_App__c);
                    }
                    if(!programMap.containsKey(mdt.Core_MDF_Program__c) && mdt.Core_MDF_isProgramApplicable__c) {
                        programMap.put(mdt.Core_MDF_Program__c, mdt.Core_MDF_Program__c);
                    }
                    if(!objectMap.containsKey(mdt.Core_MDF_Object__c)) {
                        objectMap.put(mdt.Core_MDF_Object_Label__c, mdt.Core_MDF_Object__c);
                    }
                    if(mdt.Core_MDF_Filter_Criteria__c!= null){
                        fltCriteriaWrapper = (filterCriteriaWrapper) System.JSON.deserialize(mdt.Core_MDF_Filter_Criteria__c, filterCriteriaWrapper.class);
                        //filterFieldMap.put(fltCriteriaWrapper.Label	, fltCriteriaWrapper.apiname);
                        filterFieldMap.put(mdt.Core_MDF_Object_Label__c	, fltCriteriaWrapper.Label);
                    }
       
                }
                System.debug('applicationMap'+applicationMap);
                System.debug('objectMap'+objectMap);
                if(!applicationMap.isEmpty()){
                    applicationDropdownOptions = covertMaptoWrapper(applicationMap);
                }
                if(!programMap.isEmpty()){
                    programDropdownOptions = covertMaptoWrapper(programMap);
                }
                if(!objectMap.isEmpty()){
                    objectDropdownOptions = covertMaptoWrapper(objectMap);
                }
                if(!filterFieldMap.isEmpty()){
                    fieldDropdownOptions = covertMaptoWrapper(filterFieldMap);
                }
                massOwnerWrapper.applicationList = applicationDropdownOptions;
                massOwnerWrapper.programList = programDropdownOptions;
                massOwnerWrapper.objectList = objectDropdownOptions;
                massOwnerWrapper.filterFieldList = fieldDropdownOptions;
                massOwnerWrapper.mdtList = finalMdtList;
            }
            
        } catch(Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            throw new AuraHandledException(ex.getMessage());
        }
        return massOwnerWrapper;
    }
    
    public static List<DropDownWrapper> covertMaptoWrapper(Map<String, String> inputMap) {
        List<DropDownWrapper> inpWrapperList = new List<DropDownWrapper>();
        try{
            if(!inputMap.isEmpty()) {
                for(String input: inputMap.keySet()) {
                    DropDownWrapper inpWrapper = new DropDownWrapper();
                    inpWrapper.label = input;
                    inpWrapper.value = inputMap.get(input);
                    inpWrapperList.add(inpWrapper);
                }
            }
        }
        catch(Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            throw new AuraHandledException(ex.getMessage());
        }
        return inpWrapperList;
    }
    //method to retrive program
    @AuraEnabled(cacheable=true)
    public static List<String> getProgramValues(String app)
    {
        Set<String> programdata = new Set<String>();
        List<String> programValues =new List<String>();
        for(Core_MDF_Custom_Utility_Config__c pgr:[select Core_MDF_Program__c from Core_MDF_Custom_Utility_Config__c where Core_MDF_App__c=:app order by Core_MDF_Program__c])
        {
            programdata.add(pgr.Core_MDF_Program__c);
        }
        programValues.addAll(programdata);
        return programValues;
        
    }
    //Method to retrive objects
    @AuraEnabled(cacheable=true)
    public static Map<String,String> getObjectList(String program,String app){
        Map<String,String> objectLabels=new Map<String,String>();
        for(Core_MDF_Custom_Utility_Config__c obj:[select Core_MDF_Object__c,Core_MDF_Object_Label__c from Core_MDF_Custom_Utility_Config__c where Core_MDF_Program__c=:program and Core_MDF_App__c=: app order by Core_MDF_Object_Label__c ])
        {
            objectLabels.put(obj.Core_MDF_Object__c, obj.Core_MDF_Object_Label__c);
            
        }
        return objectLabels;
    }
    @AuraEnabled(cacheable=true)
    public static List<String> getFilterFieldList(String program,String app,String obj){
        //Map<String,String> filterFieldLabels=new Map<String,String>();
        List<String> filterPickVal = new List<String>();
        filterCriteriaWrapper fltWrp = new filterCriteriaWrapper();
        /*for(Core_MDF_Custom_Utility_Config__c config:[select Core_MDF_Filter_Criteria_api_nm__c,Core_MDF_Filter_Criteria__c	 from Core_MDF_Custom_Utility_Config__c where Core_MDF_Program__c=:program and Core_MDF_App__c=: app and Core_MDF_Object__c =: obj order by Core_MDF_Filter_Criteria__c	 ])
        {
            filterFieldLabels.put(config.Core_MDF_Filter_Criteria_api_nm__c, config.Core_MDF_Filter_Criteria__c	);
            
        }*/
        Core_MDF_Custom_Utility_Config__c config = [select Core_MDF_Filter_Criteria__c from Core_MDF_Custom_Utility_Config__c where Core_MDF_Program__c=:program and Core_MDF_App__c=: app and Core_MDF_Object__c =: obj limit 1];
        fltWrp = (filterCriteriaWrapper) System.JSON.deserialize(config.Core_MDF_Filter_Criteria__c, filterCriteriaWrapper.class);
        return fltWrp.Values;
    }
     @AuraEnabled(cacheable=true)
    public static Map<String,List<filterCriteriaWrapper>> getFilterFieldWrapper(String filterCriteria){
       
        List<String> filterPickVal = new List<String>();
        filterCriteriaWrapper fltWrp = new filterCriteriaWrapper();
        Map<String,List<String>> filterFieldsList = new Map<String,List<String>>();
        Map<String,List<filterCriteriaWrapper>> filterFieldsWrpList = new Map<String,List<filterCriteriaWrapper>>();
        
        //Core_MDF_Custom_Utility_Config__c config = [select Core_MDF_Filter_Criteria__c from Core_MDF_Custom_Utility_Config__c where Core_MDF_App__c= 'CRM' and Core_MDF_Object__c = 'Opportunity'];
             
        	List<filterCriteriaWrapper> flWrppList = (List<filterCriteriaWrapper>) System.JSON.deserialize(filterCriteria,List<filterCriteriaWrapper>.class); 
             System.debug(flWrppList);
             for(filterCriteriaWrapper flWrpp:flWrppList){
            String fldType = flWrpp.fieldType;
            if(fldType == 'picklist'){
                if(filterFieldsWrpList.containsKey('picklist')){
                    filterFieldsWrpList.get('picklist').add(flWrpp);
                }
                else{
                    filterFieldsWrpList.put('picklist',new List<filterCriteriaWrapper>{flWrpp});
                }
            }
             }
        
        //for(filterCriteriaWrapper fltWrpp)
        System.debug('filterFieldsWrpList'+filterFieldsWrpList);
        return filterFieldsWrpList;
        
    }
    //Method to retrive accounts
    @AuraEnabled(cacheable=true)
    public static Map<Id,String> getAccounts()
    {
        //Set<String> acc=new Set<String>();
        Map<Id,String> accounts=new Map<Id,String>();
        for(Account a:[select Id,Name from Account where Core_Account_Record_Type__c='Intel Account' and Core_MDF_CoMarketingActive__c=true WITH SECURITY_ENFORCED order by Name asc])
        {
            accounts.put(a.Id,a.Name);
        }
        return accounts;
    }
    //Method to retrive NODE ACCOUNTS
    @AuraEnabled(cacheable=true)
    public static Map<Id,String> getAccountNodes(String account,String program)
    {
        //Set<String> accNode=new Set<String>();
        Map<Id,String> accountNode=new Map<Id,String>();  
        for(Account acc:[select Id,Name from Account where Core_MDF_CoMarketing_Ultimate_Account__c=: account and Core_MDF_Channel_Program__r.Name=:program WITH SECURITY_ENFORCED order by Name asc]){
            accountNode.put(acc.Id,acc.Name);
        } 
        return accountNode;
    }
    //method to retrive type of user
    @AuraEnabled(cacheable=true)
    public static List<String> getTypeOfFromUser()
    {
        List<String> user=new List<String>();
        user.add('External User');
        user.add('Internal User');
        user.add('System User');
        return user;
    }
    //method to fetch user
    @AuraEnabled(cacheable=true)
    public static List<SObjectResult> getUser(String userName,String typeOfUser,Id nodeAccountId,String program,String app){
        List<PermissionSetAssignment> userList =new List<PermissionSetAssignment>();
        List<SObJectResult> sObjectResultList = new List<SObJectResult>();
        /*String user='\'%'+userName+'%\'';
        String permissionSet='\''+'Core_MDF_CCP_Internal_Generic_Access'+'\'' ;
        if(typeOfUser=='Internal User')
        {
        String searchText = '\'' + String.escapeSingleQuotes(userName) + '\'';
        String query='select id, Assignee.Name from PermissionSetAssignment where PermissionSet.name=permissionSet and';
        query=query+'Assignee.Name like'+searchText.trim()+'and IsActive=true';
        System.debug(query);
        for(PermissionSetAssignment userlist1:Database.Query(query))
        {
        System.debug('valid id');
        System.debug(userName);
        sObjectResultList.add(new SObjectResult(userlist1.Assi
        gnee.Name, userlist1.Id));
        }
        }*/
        if(app != 'CRM'){
            if(typeOfUser=='Internal User') {
                if(String.isNotEmpty(userName))
                {
                    string searchText = '\'%' + String.escapeSingleQuotes(userName) +'%\'';
                    String query='select id,Assignee.Name, Assignee.Email from PermissionSetAssignment where PermissionSet.Name='+'\''+'Core_MDF_CCP_Internal_Generic_Access'+'\''+'and Assignee.Name like';
                    query=query+searchText.trim()+' LIMIT 10';               
                    //query = query+' From'+'PermissionSetAssignment'+' Where PermissionSet.Name='+'\''+'Core_MDF_CCP_Internal_Generic_Access'+'\''+'and Assignee.Name like'+searchText.trim();
                    system.debug(query);       
                    
                    for(PermissionSetAssignment userlist1 :Database.Query(query)) 
                    {
                        system.debug(query);
                        System.debug('valid id');
                        System.debug(userName);
                        sObjectResultList.add(new SObjectResult(userlist1.Assignee.Name, userlist1.Id, userlist1.Assignee.Email));
                        System.debug('sobject'+sObjectResultList);
                    }
                }
            }
            
            /* else{
            string searchText = '\'' + String.escapeSingleQuotes(userName) + '%\'';
            query = query+' FROM '+'User'+' WHERE Name like ' + searchText.trim()+'and Profile.Name like'+profileName;
            system.debug(query);
            for(User userlist1 : Database.Query(query)) 
            {
            System.debug('valid id');
            System.debug(userName);
            sObjectResultList.add(new SObjectResult(userlist1.Name, userlist1.Id));
            }

            }*/
            else if(typeOfUser=='External User') {
                if(String.isNotEmpty(userName)){
                    string searchText = '\'%' + String.escapeSingleQuotes(userName) +'%\'';
                    String query='select id,Core_MDF_User__r.Name,Core_MDF_User__r.Email, Core_MDF_Account__r.Name from Core_MDF_Partner_Node_User_Mapping__c where Core_MDF_Account__c='+'\''+nodeAccountId+'\''+'and  Core_MDF_Active_Ind__c =true and Core_MDF_Account__r.Core_MDF_Channel_Program__r.Name='+'\''+program+'\''+'and Core_MDF_Account__r.Core_MDF_Active_Ind__c = true ' ;
                    query=query+'and Core_MDF_User__r.Name like'+searchText.trim()+' LIMIT 10';
                    system.debug(query);
                    for(Core_MDF_Partner_Node_User_Mapping__c userlist1 :Database.Query(query)) 
                    {
                        system.debug(query);
                        System.debug('valid id');
                        System.debug(userName);
                        sObjectResultList.add(new SObjectResult(userlist1.Core_MDF_User__r.Name, userlist1.Id,userlist1.Core_MDF_User__r.Email));
                    }
                    
                }
            }
            else if(typeOfUser=='System User') {
                if(String.isNotEmpty(userName))
                {
                    string searchText = '\'%' + String.escapeSingleQuotes(userName) +'%\'';
                    if(app=='CCP')
                    {
                        Core_MDF_Custom_Utility_Config__c mdt=[select id, Core_MDF_System_User_Name__c from Core_MDF_Custom_Utility_Config__c where Core_MDF_App__c=:app and Core_MDF_System_User_Name__c!=null  limit 1];
                        System.debug(mdt.Core_MDF_System_User_Name__c );
                        User usr=[select id,name from User where name=:mdt.Core_MDF_System_User_Name__c];
                        System.debug(usr);
                        sObjectResultList.add(new SObjectResult(usr.name, usr.Id, ''));
                        System.debug(sObjectResultList);
                    }
                }
            }
        }
        else if (app=='CRM'){
            if(String.isNotEmpty(userName)){
                string searchText = '\'%' + String.escapeSingleQuotes(userName) +'%\'';
                String query='Select id,name,Email from user where Profile.name in (\'Sales Manager\',\'Sales Ops\',\'Sales Rep-BB\',\'Sales Rep-BB-Dual IPS\',\'Sales Rep-CW\',\'SMG/GMC Read Only\',\'System Administrator\')'+' and Name like';
                query=query+searchText.trim()+' LIMIT 10';  
                System.debug('CRM query'+query);
                for(user userlist1 :Database.Query(query)) {
                    system.debug(query);
                    System.debug('valid id');
                    System.debug(userName);
                    sObjectResultList.add(new SObjectResult(userlist1.Name, userlist1.Id,userlist1.Email));
                }
            }
        }
        System.debug('sobject'+sObjectResultList);
        return sObjectResultList;
    }
    //method to get object transactions
    @AuraEnabled(cacheable=true)
    public static List<Object> getObjectTransactions(String program,String objectname,String accountId,String user,String typeOfUser,List<String> filterCriteria, DateTime startDate, DateTime endDate, List<Id> selectedIds)
    {
        Map<String,String> programs=new Map<String,String>();
        List<Object> trans=new List<Object>();
        System.debug('objectname'+objectname);
        System.debug('Program'+program);
        System.debug('accountId'+accountId);
        programs.put('Client','Client CoMarketing Fund');
        programs.put('Client Co-Marketing Fund Boost','Client CoMarketing Fund Boost');
        programs.put('Datacenter','Data Center CoMarketing Fund');
        programs.put('Intel Partner Alliance','Intel Partner Alliance');
        programs.put('Retail Marketing Funds','Retail Marketing Funds');
        programs.put('Service Provider Co-Marketing Fund','Service Provider CoMarketing Fund');
        DateTime startDateVal;
        DateTime endDateVal;
        /*if(startDate!=null){
            startDateVal = DateTime.valueOf(startDate);
        }
        if(endDate != null){
            endDateVal = DateTime.valueOf(endDate);
        }*/
        String prog = programs.get(program);
        String query ='Select id,Owner.Name,Owner.Email,';
        if(objectname =='Campaign'||objectname =='Core_MDF_Account_Bank_Mapping__c')
        {
            query+='Name,Core_MDF_Program__c,Core_MDF_Account__r.name,Core_MDF_Account__c  from ';
            query+=objectname+' where';
            if(selectedIds != null && !selectedIds.isEmpty()){
                query+=' Id in :selectedIds ';
            }
            else{
                query+=' Core_MDF_Program__c=:prog'+' and Owner.Name=:user ';
                if(objectname =='Campaign'){
                    query+='and status != \'Cancelled\'';
                }
                if(typeOfUser=='External User')
                {
                    query+=' and Core_MDF_Account__c=:accountId ';
                }
            }
            System.debug(query);
            
            
            query+= 'order by Name';
            System.debug(query);
        }
        else if(objectname=='PartnerFundClaim'|| objectname=='PartnerFundRequest')
        {
            query+='Title,Core_MDF_Program__c,ChannelPartner.Name,ChannelPartnerId from ';
            query+=objectname+' where';
            if(selectedIds != null && !selectedIds.isEmpty()){
                query+=' Id in :selectedIds ';
            }
            else{
                query+=' Core_MDF_Program__c=:program'+' and owner.Name=:user';
                if(objectname == 'PartnerFundRequest'){
                    query+= ' and Core_MDF_Fund_Request_Status__c != \'Cancelled\'';
                }
                else if(objectname == 'PartnerFundClaim'){
                    query+= ' and Core_MDF_Status__c != \'Cancelled\' and Core_MDF_Status__c != \'Resubmission Window Closed\'';
                }
                if(typeOfUser=='External User')
                {
                    query+=' and ChannelPartnerId=:accountId';
                }
            }
            query+=' order by Title';
            System.debug('query'+query);
        }
        else if(objectname=='Core_MDF_Audit_Document__c')
        {
            query+='Name,Core_MDF_Claim__r.Core_MDF_Program__c,Core_MDF_Claim__r.ChannelPartner.name,Core_MDF_Claim__r.ChannelPartnerId from ';
            query+=objectname+' where Core_MDF_Claim__r.Core_MDF_Program__c=:program'+' and owner.name=:user';
            if(typeOfUser=='External User')
            {
                query+=' and Core_MDF_Claim__r.ChannelPartnerId=:accountId ';
            }
            query+=' order by Name';
            System.debug('query'+query);
        }
        else if(objectname=='Core_MDF_Claim_Batch__c')
        {
            query+='Name,Core_MDF_Program_Id__r.name,Core_MDF_Account__c,Core_MDF_Account__r.name from ';
            query+=objectname+' where Core_MDF_Program_Id__r.name=:program'+' and owner.name=:user';
            if(typeOfUser=='External User')
            {
                query+=' and Core_MDF_Account__c=:accountId';
            }
            query+=' order by Name';
            System.debug('query'+query);
        }
        else if(objectname=='Account'){
            query+='Name,Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c from ';
            query+=objectname+' where Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c=:prog'+' and owner.name=:user';
            query+=' order by Name';
        }
        else if(objectname == 'Lead'){
            query+='Name,Company,Core_Lead_Status__c,CreatedDate,Email from ';
            query+=objectname+' where';
            if(selectedIds != null && !selectedIds.isEmpty()){
                query+=' Id in :selectedIds ';
            }
            else{
                query+=' owner.name=:user';
                if(filterCriteria!=null){
                    query+=' and Core_Lead_Status__c in :filterCriteria and createdDate >= :startDate and createdDate <= :endDate';               
                }
            }
            query+=' order by Name';
        }
        else if(objectName == 'Opportunity'){
            query+='Name,AccountId,StageName,Core_Opportunity_Owner__c,Core_Technical_Owner__c,CloseDate,CreatedDate,LastModifiedDate,Core_Opportunity_ID__c from ';
            query+=objectname+' where';
            if(selectedIds != null && !selectedIds.isEmpty()){
                query+=' Id in :selectedIds ';
            }
            else{
                query+= ' owner.name=:user';
                if(filterCriteria!=null || startDate != null || endDate != null){
                    query+= ' and StageName in :filterCriteria and createdDate >= :startDate and createdDate <= :endDate';
                }
            }
            query+=' order by Name';
        }
        System.debug('query'+query);
        trans=Database.query(query);
        System.debug('trans'+trans);
        return trans;
    }
    //method to get touser
    @AuraEnabled
    public static List<SObjectResult> getToUser(String program,String userName,String typeOfUser,String obj,String App)
    {
        List<SObJectResult> sObjectResultList = new List<SObJectResult>();
        List<String> perm=new List<String>();
        string searchText = '\'%' + String.escapeSingleQuotes(userName) +'%\'';
        if(App=='CCP'){
            Core_MDF_Custom_Utility_Config__c ps=[select id, Core_MDF_Int_Permision_Set_Name__c	 from Core_MDF_Custom_Utility_Config__c where Core_MDF_Program__c=:program  and  Core_MDF_Object__c =:obj];
            String permissionset=String.valueOf(ps.Core_MDF_Int_Permision_Set_Name__c	);
            system.debug('internalps'+ permissionset);
            if(permissionset.contains(','))
            {
                perm=permissionset.split(',');
                System.debug('perm'+perm);
                String pset='(\''+String.join(perm,'\',\'')+'\')';
                System.debug('pset  '+pset);
                //string searchText = '\'%' + String.escapeSingleQuotes(userName) +'%\'';
                String query='select id,AssigneeId,Assignee.Name, Assignee.Email from PermissionSetAssignment where PermissionSet.Name in'+pset+' and IsActive=true'+' and Assignee.Name like ';
                query=query+ searchText.trim();
                System.debug(query);
                for(PermissionSetAssignment userlist1 :Database.Query(query)) 
                {
                    System.debug('inside for loop');
                    system.debug(query);
                    System.debug('valid id');
                    System.debug(userName);
                    sObjectResultList.add(new SObjectResult(userlist1.Assignee.Name, userlist1.AssigneeId, userlist1.Assignee.Email));
                }
                System.debug(sObjectResultList);
                
                
            }
            else
            {
                //string searchText = '\'%' + String.escapeSingleQuotes(userName) +'%\'';
                String query='select id,AssigneeId,Assignee.Name, Assignee.Email from PermissionSetAssignment where PermissionSet.Name='+'\''+permissionset+'\''+' and IsActive=true'+' and Assignee.Name like ';
                query=query+ searchText.trim();
                System.debug(query);
                for(PermissionSetAssignment userlist1 :Database.Query(query)) 
                {
                    System.debug('inside for loop');
                    system.debug(query);
                    System.debug('valid id');
                    System.debug(userName);
                    sObjectResultList.add(new SObjectResult(userlist1.Assignee.Name, userlist1.AssigneeId,userlist1.Assignee.Email));
                }
                System.debug(sObjectResultList);
            }   
        }
        if(App=='CRM'){
            String query='Select id,name,Email from user where Profile.name in (\'Sales Manager\',\'Sales Ops\',\'Sales Rep-BB\',\'Sales Rep-BB-Dual IPS\',\'Sales Rep-CW\',\'SMG/GMC Read Only\',\'System Administrator\')'+' and Name like';
            query=query+ searchText.trim();
            System.debug('query at386'+query);
            for(user userlist1 :Database.Query(query)) 
                {
                    System.debug('inside for loop');
                    system.debug(query);
                    System.debug('valid id');
                    System.debug(userName);
                    sObjectResultList.add(new SObjectResult(userlist1.Name, userlist1.Id,userlist1.Email));
                }
            System.debug('395 sobjectResult'+sObjectResultList);
        }
        return sObjectResultList;        
    }
    
    //method to get touser
    @AuraEnabled
    public static List<SObjectResult> getToUserForPhysical(String userName)
    {
        List<SObJectResult> sObjectResultList = new List<SObJectResult>();
        
        string searchText = '\'%' + String.escapeSingleQuotes(userName) +'%\'';
        String query='select id,name from Account where '+ ' Name like ';
        query=query+ searchText.trim();
        System.debug(query);
        for(Account userlist1 :Database.Query(query)) 
        {
            
            sObjectResultList.add(new SObjectResult(userlist1.Name, userlist1.Id, userlist1.Id));
        }
        
        return sObjectResultList;        
    }
    public class SObjectResult {
        @AuraEnabled
        public String recName;
        @AuraEnabled
        public Id recId;
        @AuraEnabled
        public String email;
        
        
        public SObJectResult(String recNameTemp, Id recIdTemp, String emailTemp) {
            recName = recNameTemp;
            recId = recIdTemp;
            email = emailTemp;
        }
        public SObjectResult() {
            
        }
    }
    
    //method to update owner
    @AuraEnabled
    public static ownerUpdateWrapper updateOwner(List<id> selectedRowIds,Id toUser,Id fromUser, String obj)
    {
        ownerUpdateWrapper updatedWrapper = new ownerUpdateWrapper();
        boolean res=false;
        Set<Id> rowIds =new Set<Id>();
        System.debug('selectedRowIds'+selectedRowIds);
        System.debug('toUser'+toUser);
        System.debug('obj'+obj);
        try
        {
            Integer batchSize = Integer.valueOf(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BatchSizing_MassOwnerUpdate'));
            if(selectedRowIds.size() > batchSize)
            {
                //call Batch class
                for(Integer i=0;i<selectedRowIds.size(); i++)
                {
                    rowIds.add(selectedRowIds[i]);
                }
                //Id batchInstanceId = Database.executeBatch(new Core_MDF_Batch_MassOwnerUpdate(obj,rowIds,toUser),1000);
                //res=true;
                updatedWrapper.res = true;
            }
            else {
                System.debug('else block');
                List<sObject> sObjectsToUpdate = new List<sObject>();
                List<objectTransactionDetailsWrapper> objTranscWrapperList = new List<objectTransactionDetailsWrapper>();
                String sQuery = 'SELECT Id,OwnerId FROM ' + obj + ' WHERE ' + ' Id IN : '+ 'selectedRowIds';
                System.debug('sQuery::'+sQuery);
                List<sObject> scope = Database.Query(sQuery);
                System.debug('scope'+scope);
                for(sObject record : scope)
                {
                    Id rec = String.valueOf(record.get('Id'));
                    SObject o1 = record.getSObjectType().newSObject(rec);    // Set the Name field dynamically
                    o1.put('OwnerId', toUser);
                    sObjectsToUpdate.add(o1);
                    
                }
                System.debug('sObjectsToUpdate'+sObjectsToUpdate);
                //update sObjectsToUpdate; 
                boolean isUpdated = saveResult(sObjectsToUpdate);
                System.debug('isupdated'+isUpdated);
                if(isUpdated){
                    List<Object> updatedRecordList = getObjectTransactions(null,obj,null,null,null,null,null,null,selectedRowIds);
                    updatedWrapper.updatedRecordsList = updatedRecordList;
                }
                updatedWrapper.res = isUpdated;
                //Status of the update
                //Prepare a list<Wrapper>
                
                //res=true;
            }       
        }
        catch(Exception e) {
            System.debug('An unexpected error has occurred: ' + e.getMessage());
        }
        return updatedWrapper;
    }
    public static boolean saveResult(List<sobject> sObjectsToUpdate){
        boolean isupdated = false;
        Database.UpsertResult[] saveList = Database.upsert(sObjectsToUpdate,true);
        String errs = '';
        for(Database.UpsertResult sr : saveList) {
            if(sr.isSuccess()){
                isupdated = true;
            } else {
                isupdated = false;
                if (!sr.isSuccess()) {  
                    for(Database.Error err : sr.getErrors()) {  
                        errs += ' ' + err.getMessage();
                    }
                }
            }
        }
        return isupdated;
        
    }
    @AuraEnabled(cacheable=true)
    public static List<sObject> getObjectRecords(String userId, String objectApiName) {
        String query = 'SELECT Id, Name, Owner.Name,Owner.Email FROM ' + objectApiName + ' WHERE OwnerId = :userId';
        return Database.query(query);
    }
    @AuraEnabled(cacheable=true)
    public static List<String> getDynamicColumnHeaders(String app, String obj) {
        // You can populate this list dynamically based on your logic
        // For example, this could be fetched from a custom object or metadata
        List<String> columns = new List<String>();
        Core_MDF_Custom_Utility_Config__c mdt= [Select Core_MDF_Column_Headers__c from Core_MDF_Custom_Utility_Config__c where Core_MDF_App__c =: app and Core_MDF_Object__c =: obj limit 1];
        columns = mdt.Core_MDF_Column_Headers__c.split(',');
        return columns;
    }

    
    public class DropDownWrapper {
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public String value {get; set;}
    }
    
    public class MassOwnerMdtWrapper {
        @AuraEnabled
        public List<DropDownWrapper> applicationList {get; set;}
        @AuraEnabled
        public List<DropDownWrapper> programList {get; set;}
        @AuraEnabled
        public List<DropDownWrapper> objectList {get; set;}
        @AuraEnabled
        public List<DropDownWrapper> filterFieldList {get; set;}
        @AuraEnabled
        public List<Core_MDF_Custom_Utility_Config__c> mdtList {get; set;}
    }
    public class ownerUpdateWrapper {
        @AuraEnabled
        public boolean res {get;set;}
        @AuraEnabled
        public List<Object> updatedRecordsList {get;set;}
        
    }
    public class objectTransactionDetailsWrapper {
        @AuraEnabled
        public Id Id {get;set;}
        @AuraEnabled
        public String Name {get;set;}
        @AuraEnabled
        public String program {get;set;}
        @AuraEnabled
        public String ownerName {get;set;}
        @AuraEnabled
        public String accountName {get;set;}
        @AuraEnabled
        public Id accountId {get;set;}
        @AuraEnabled
        public String ownerEmail {get;set;}
        
        
    }
      public class filterCriteriaWrapper {
        @AuraEnabled
        public String label {get;set;}
         @AuraEnabled
        public String apiName {get;set;}
          @AuraEnabled
        public List<String> values {get;set;}
        @AuraEnabled
        public String fieldType {get;set;}
    }
}