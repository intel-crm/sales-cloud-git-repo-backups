public with sharing class Core_MDF_CCP_MassOwnerUpdate {
    //method to retrive app values
    @AuraEnabled(cacheable=true)
    public static MassOwnerMdtWrapper getAppValues()
    {
        Map<String, String> applicationMap= new Map<String, String>();
        Map<String,Map<String,String>> appProgramMap = new Map<String,Map<String,String>>();
        List<Core_MDF_Custom_Utility_Config__c> mdtList =new List<Core_MDF_Custom_Utility_Config__c>();
        Map<String,List<Core_MDF_Custom_Utility_Config__c>> finalMdtList = new Map<String,List<Core_MDF_Custom_Utility_Config__c>>();
        List<DropDownWrapper> applicationDropdownOptions = new List<DropDownWrapper>();
        Map<String,List<DropDownWrapper>> appProgramDropdownOptions = new Map<String,List<DropDownWrapper>>();
        MassOwnerMdtWrapper massOwnerWrapper = new MassOwnerMdtWrapper();
        
        
        try {
            mdtList = [select Core_MDF_App_nm__c, Core_MDF_Program_nm__c, Core_MDF_Object_apiName_nm__c, Core_MDF_Object_Label_nm__c, Core_MDF_Filter_Criteria_txt__c,Core_MDF_Int_PermisionSet_Names_txt__c, Core_MDF_Ext_PermissionSet_Names_txt__c, Core_MDF_System_User_Name_txt__c, Core_MDF_isProgramApplicable_Ind__c,Core_MDF_requiredQueryFields_txt__c,Core_MDF_Mandatory_Filter_Fields_txt__c,Core_MDF_Record_Types_nm__c,Core_MDF_Name_field_nm__c,Core_MDF_Account_Field_nm__c,Core_MDF_Profiles_nm__c,Core_MDF_Column_Headers_txt__c,
                                                                                                Core_MDF_Batch_Size_nbr__c,Core_MDF_Type_of_From_User_nm__c,Core_MDF_Type_of_To_User_nm__c,Core_MDF_Ultimate_Account_Field_txt__c,Core_MDF_Free_Search_Ind__c,Core_MDF_Enable_Account_Filter_Ind__c from Core_MDF_Custom_Utility_Config__c where Core_MDF_isActive_Ind__c = true
                                                                                                order by Core_MDF_App_nm__c];
            if(!mdtList.isEmpty()) {
                for(Core_MDF_Custom_Utility_Config__c mdt: mdtList) {
                    String key=mdt.Core_MDF_App_nm__c;
                    if(mdt.Core_MDF_isProgramApplicable_Ind__c){
                        key+=mdt.Core_MDF_Program_nm__c;
                        
                            if(appProgramMap.containsKey(mdt.Core_MDF_App_nm__c)){
                                //appProgramMap.get(mdt.Core_MDF_App_nm__c).put(mdt.Core_MDF_Program_nm__c,mdt.Core_MDF_Program_nm__c);
                                Map<String, String> innerMap = appProgramMap.get(mdt.Core_MDF_App_nm__c);
    
                                // Check if the key already exists in the inner map
                                if (!innerMap.containsKey(mdt.Core_MDF_Program_nm__c)) {
                                    // If it doesn't exist, add the program to the inner map
                                    innerMap.put(mdt.Core_MDF_Program_nm__c, mdt.Core_MDF_Program_nm__c);
                                }
                            }
                            else{
                                Map<String,String> innerMap = new Map<String,String>();
                                innerMap.put(mdt.Core_MDF_Program_nm__c,mdt.Core_MDF_Program_nm__c);
                                appProgramMap.put(mdt.Core_MDF_App_nm__c,innerMap);
                            }
                           // programMap.put(mdt.Core_MDF_Program_nm__c,mdt.Core_MDF_Program_nm__c);
                       
                    }
                    if(finalMdtList.containsKey(key)){
                        finalMdtList.get(key).add(mdt);
                    }
                    else{
                        finalMdtList.put(key,new List<Core_MDF_Custom_Utility_Config__c>{mdt});
                    }
                    //finalMdtList.add(mdt);
                    if(!applicationMap.containsKey(mdt.Core_MDF_App_nm__c)) {
                        applicationMap.put(mdt.Core_MDF_App_nm__c, mdt.Core_MDF_App_nm__c);
                    }
                    //Map<Key = app,List<Map<Program,Program>>

                    for (String appName : appProgramMap.keySet()) {
                        // Get the inner map for the current application (appName)
                        Map<String, String> innerMap = appProgramMap.get(appName);
                        List<DropDownWrapper> programOptions = new List<DropDownWrapper>();
                        if(!innerMap.isEmpty()){
                            programOptions =covertMaptoWrapper(innerMap);
                        }
                         
                        appProgramDropdownOptions.put(appName,programOptions);
                        
                    }
                }
                if(!applicationMap.isEmpty()){
                    applicationDropdownOptions = covertMaptoWrapper(applicationMap);
                }
                massOwnerWrapper.applicationList = applicationDropdownOptions;
                massOwnerWrapper.mdtList = finalMdtList;
                massOwnerWrapper.appWithProgramList = appProgramDropdownOptions;
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
    @AuraEnabled
    public static Map<String,List<filterCriteriaWrapper>> getFilterFieldWrapper(String filterCriteria){
       
        List<String> filterPickVal = new List<String>();
        filterCriteriaWrapper fltWrp = new filterCriteriaWrapper();
        Map<String,List<String>> filterFieldsList = new Map<String,List<String>>();
        Map<String,List<filterCriteriaWrapper>> filterFieldsWrpList = new Map<String,List<filterCriteriaWrapper>>();
        try{
        	List<filterCriteriaWrapper> flWrppList = (List<filterCriteriaWrapper>) System.JSON.deserialize(filterCriteria,List<filterCriteriaWrapper>.class); 
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
            if(fldType == 'date'){
                if(filterFieldsWrpList.containsKey('date')){
                    filterFieldsWrpList.get('date').add(flWrpp);
                }
                else{
                    filterFieldsWrpList.put('date',new List<filterCriteriaWrapper>{flWrpp});
                }
            }
            if(fldType == 'text'){
                if(filterFieldsWrpList.containsKey('text')){
                    filterFieldsWrpList.get('text').add(flWrpp);
                }
                else{
                    filterFieldsWrpList.put('text',new List<filterCriteriaWrapper>{flWrpp});
                }
            }
             }
        }
        catch(Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            throw new AuraHandledException(ex.getMessage());
        }
        return filterFieldsWrpList;
        
    }
    //Method to retrive accounts
    @AuraEnabled
    public static List<sObjectResult> getAccounts(String program,String accName)
    {
        //Set<String> acc=new Set<String>();
        List<sObjectResult> sObjectResultList = new list<sObjectResult>();
        List<Account> accList = new List<Account>();
        try{
            String crm_RecType = '';
            List<String> crm_Acc_RecordType_Names = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_MOU_CRM_Account_RecType_DevName').split(';');
            if(crm_Acc_RecordType_Names!=null && crm_Acc_RecordType_Names.size()>0){
                crm_RecType = '(\'' + String.join(crm_Acc_RecordType_Names, '\', \'') + '\')';
            }
            string searchText = '\'%' + String.escapeSingleQuotes(accName) +'%\'';
            String query='select Id, Name, Core_MDF_Parent_Fund_Account__r.name,Core_MDF_Parent_Fund_Account__c from Account Where';
            if(program != ''){ 
                 query += ' Core_MDF_Parent_Fund_Account__r.Core_MDF_CoMarketingActive__c = true ';
                query+=' and Core_MDF_Channel_Program__r.name ='+'\''+program+'\''+'  and Core_MDF_Active_Ind__c = true and Core_MDF_Parent_Fund_Account__r.name like ';
            }
            else{
                query += ' RecordType.DeveloperName in '+crm_RecType;
                query +=  ' and Name like ';

            }
            query=query+searchText.trim()+' LIMIT 10';
        for(Account a:Database.query(query))
        {
            if(program != ''){ 
            sObjectResultList.add(new SObjectResult(a.Core_MDF_Parent_Fund_Account__r.Name, a.Core_MDF_Parent_Fund_Account__c,null));
            }
            else{
                sObjectResultList.add(new SObjectResult(a.Name, a.Id,null)); 
            }
        }
        }
        catch(Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            throw new AuraHandledException(ex.getMessage());
        }
        return sObjectResultList;
        //return accList;
    }
    //Method to retrive NODE ACCOUNTS
    @AuraEnabled
    public static Map<Id,String> getAccountNodes(String account,String program)
    {
        Map<Id,String> accountNode=new Map<Id,String>();
        try{
        for(Account acc:[select Id,Name from Account where Core_MDF_CoMarketing_Ultimate_Account__c=: account and Core_MDF_Channel_Program__r.Name=:program  and Core_MDF_Active_Ind__c = true WITH SECURITY_ENFORCED order by Name asc]){
            accountNode.put(acc.Id,acc.Name);
        } 
        }
        catch(Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            throw new AuraHandledException(ex.getMessage());
        }
        return accountNode;
    }
    
    //method to fetch user
    @AuraEnabled
    public static List<SObjectResult> getUser(String userName,String typeOfUser, Id nodeAccountId,Core_MDF_Custom_Utility_Config__c objConfigRec){
        List<SObJectResult> sObjectResultList = new List<SObJectResult>();
        String objectName = objConfigRec.Core_MDF_Object_Label_nm__c;
        String projectName = objConfigRec.Core_MDF_App_nm__c;

        try{
        List<PermissionSetAssignment> userList =new List<PermissionSetAssignment>();
        String systemUser = objConfigRec.Core_MDF_System_User_Name_txt__c;
        List<String> profileList = new List<String>();
        String profileStr='';
        String program = objConfigRec.Core_MDF_Program_nm__c!=null?objConfigRec.Core_MDF_Program_nm__c:'';
        if(objConfigRec.Core_MDF_Profiles_nm__c!=null){
            profileList=objConfigRec.Core_MDF_Profiles_nm__c.split(',');
            profileStr = '(\''+String.join(profileList,'\',\'')+'\')';
        }

        //fromUserfreesearch as a ind is true: directly query on user: if not: rely on PS with profile if it is not blank, if not we can query on profile & PS level
        if(objConfigRec.Core_MDF_Free_Search_Ind__c){
            if(typeOfUser=='Internal User') {
                if(String.isNotEmpty(userName))
                {
                    //query on user with Name or email Id or WW1d check with the entered text for From User
                    List<Id> userWithGenericPS = new List<Id>();
                    boolean isNumber = String.escapeSingleQuotes(userName).isNumeric();
                    string searchText = '\'%' + String.escapeSingleQuotes(userName) +'%\'';
                    String query = 'Select id,name,email from user where UserType = \'Standard\' and ( name like '; //UserType = standard not with profile
                    query=query+searchText.trim()+'or email like ';
                    query=query+searchText.trim();
                    if(isNumber){
                        query = query + 'or Core_WWID__c = '+searchText.trim();
                    } 
                    query = query+') LIMIT 10';                
                    for(user usr:Database.Query(query)){
                        sObjectResultList.add(new SObjectResult(usr.name, usr.id, usr.email));
                    }
                }
            }
            else if(typeOfUser=='External User') {
                if(String.isNotEmpty(userName)){
                    string searchText = '\'%' + String.escapeSingleQuotes(userName) +'%\'';
                    String query='select id,Core_MDF_User__c,Core_MDF_User__r.Name,Core_MDF_User__r.Email, Core_MDF_Account__r.Name from Core_MDF_Partner_Node_User_Mapping__c where Core_MDF_Account__c='+'\''+nodeAccountId+'\''+'and  Core_MDF_Active_Ind__c =true and Core_MDF_Account__r.Core_MDF_Channel_Program__r.Name='+'\''+program+'\''+'and Core_MDF_Account__r.Core_MDF_Active_Ind__c = true ' ;
                    query=query+'and (Core_MDF_User__r.Name like'+searchText.trim()+ 'or Core_MDF_User__r.Email like'+searchText.trim()+') LIMIT 10';
                    List<Core_MDF_Partner_Node_User_Mapping__c> pnumList = new List<Core_MDF_Partner_Node_User_Mapping__c>();
                    pnumList = Database.Query(query);
                    if(pnumList.size()>0){
                        for(Core_MDF_Partner_Node_User_Mapping__c userlist1 :pnumList) 
                        {
                            sObjectResultList.add(new SObjectResult(userlist1.Core_MDF_User__r.Name, userlist1.Core_MDF_User__c,userlist1.Core_MDF_User__r.Email));
                        }
                    }
                    else{
                        boolean isNumber = String.escapeSingleQuotes(userName).isNumeric();
                        query = 'Select id,name,email from user where UserType = \'PowerPartner\' and ( name like '; //UserType = standard not with profile
                        query=query+searchText.trim()+'or email like ';
                        query=query+searchText.trim();
                        if(isNumber){
                            query = query + 'or Core_WWID__c = '+searchText.trim();
                        } 
                        query = query+') LIMIT 10';  
                        for(user usr:Database.Query(query)){
                            sObjectResultList.add(new SObjectResult(usr.name, usr.id, usr.email));    
                        }  
                    }
                    
                }
                //query on user with powerpartner type for other APT
            }
            else if(typeOfUser=='System User') {
                if(String.isNotEmpty(userName))
                {
                    string searchText = '\'%' + String.escapeSingleQuotes(userName) +'%\'';
                        User usr=[select id,name from User where name=:systemUser];
                        sObjectResultList.add(new SObjectResult(usr.name, usr.Id, ''));
                }
            }
        }
        else if (profileStr!=''){
            if(String.isNotEmpty(userName)){
                string searchText = '\'%' + String.escapeSingleQuotes(userName) +'%\'';
                String query='Select id,name,Email from user where  Profile.name in '+profileStr+' and (Name like '+searchText.trim()+ 'or Email like '+searchText.trim()+')'+' LIMIT 10'; 
                for(user userlist1 :Database.Query(query)) {
                    sObjectResultList.add(new SObjectResult(userlist1.Name, userlist1.Id,userlist1.Email));
                }
            }
        }
        }
        catch(Exception ex) {
            
            Core_MDF_CCP_UtilityClass.triggerErrLoggingPE(ex,'Critical',projectName,objectName,'Mass Access Ownership Transfer',null);      
            throw new AuraHandledException(ex.getMessage());
        }
         return sObjectResultList;
    }
    //method to get object transactions
    @AuraEnabled
    public static List<Map<String, Object>> getObjectTransactions(String program,Id accountId,Id ultimateAccId,Id fromUser,Id toUser,String typeOfUser,FilterFieldsWrapper filtFldWrapper, Core_MDF_Custom_Utility_Config__c objConfigRec, List<Id> selectedIds)
    {
                List<SObject> trans=new List<SObject>();
                List<String> jsonResults = new List<String>();
                List<Map<String, Object>> res = new List<Map<String, Object>>();
                String projectName = objConfigRec.Core_MDF_App_nm__c;
                String objectNm = objConfigRec.Core_MDF_Object_Label_nm__c;

        try{
       
        String queryFieldsString='';
        String mandatFiltCondition ='';  
        String nameField='';
        String recordTypeIds='';
        String accountField ='';
        String objectname = '';
        String ultAccField = '';
      
        if(objConfigRec!=null){
            queryFieldsString =  objConfigRec.Core_MDF_requiredQueryFields_txt__c;
            mandatFiltCondition = objConfigRec.Core_MDF_Mandatory_Filter_Fields_txt__c;
            nameField = objConfigRec.Core_MDF_Name_field_nm__c;
            recordTypeIds = objConfigRec.Core_MDF_Record_Types_nm__c;
            accountField = objConfigRec.Core_MDF_Account_Field_nm__c;
            objectname = objConfigRec.Core_MDF_Object_apiName_nm__c;
            ultAccField =  objConfigRec.Core_MDF_Ultimate_Account_Field_txt__c;          
        }

        // make inprogress records readonly
        Set<Id> lockedRecordIds = new Set<Id>();
        for (Core_MDF_Batch_Request_and_Update_Log__c log : [SELECT Core_MDF_Record_Ids_Id__c FROM Core_MDF_Batch_Request_and_Update_Log__c WHERE Core_MDF_Status__c IN ('Pending', 'In Progress') AND Core_MDF_Object_apiName_nm__c = :objectname]) {
            lockedRecordIds.add(log.Core_MDF_Record_Ids_Id__c);
        }

        List<picklistFilterFldWrapper> picklistFldWrpList = new List<picklistFilterFldWrapper>();
        List<dtFilterFldWrapper> dtFilterFldWrapperList = new List<dtFilterFldWrapper>();
        List<txtFilterFldWrapper> txtFilterFldWrapperList = new List<txtFilterFldWrapper>();
        String query = '';

        if(objectName == 'Reports' || objectName == 'Dashboards'){
            //call the respestive methods
            if(objectName == 'Reports')   {
                trans = UserReports( fromUser, toUser);
            } 
            if(objectName == 'Dashboards'){
                return CRM_Create_Dashbord_detail.Create_Dasboard_Data(fromUser, toUser);
            }
                
            }
        else{
            query ='Select ';
            if(queryFieldsString!=''){
                query+=queryFieldsString;
            }
            query+=' from '+objectname+' where';
            if(selectedIds != null && !selectedIds.isEmpty()){
                query+=' Id in :selectedIds ';
            }
            else{
                
                  query+= ' ownerId=:fromUser';  
               
                if(mandatFiltCondition!=null){
                    query+=' and '+mandatFiltCondition;
                }
                if(recordTypeIds!=null && recordTypeIds!=''){
                    List<String> recIds =recordTypeIds.split(',');
                    String recIdVal ='';
                    if(recIds!=null && recIds.size()>0){
                        recIdVal = '(\'' + String.join(recIds, '\', \'') + '\')';
                    }
                    query+=' and RecordType.DeveloperName in '+recIdVal;
                     
                }
                if(accountField!='' && accountField!=null && accountId!= null){
                    query+=' and '+accountField+' =:accountId';
                }
                if(ultAccField!='' && ultimateAccId!=null){
                    query+=' and '+ultAccField+' =:ultimateAccId';
                }
                if(filtFldWrapper!=null && filtFldWrapper!=null){
                    if(filtFldWrapper.picklistFiltFldWrapList!=null){
                        picklistFldWrpList = filtFldWrapper.picklistFiltFldWrapList;
                        for(picklistFilterFldWrapper pickWrp:picklistFldWrpList){
                            String filterVal='';
                            if(pickWrp.value != null && pickWrp.value.size() >0){
                                filterVal ='(\'' + String.join(pickWrp.value, '\', \'') + '\')';
                                query+= ' and '+pickWrp.apiName + ' in '+ filterVal;}
                        }
                    }
                    if(filtFldWrapper.dtFiltFldWrapList!=null){
                        dtFilterFldWrapperList = filtFldWrapper.dtFiltFldWrapList;
                        for(dtFilterFldWrapper dtWrp:dtFilterFldWrapperList){
                            if(dtWrp.startRange!=null ){
                                Date  startDateRange = (Date)dtWrp.startRange; 
                                query+= ' and '+dtWrp.apiName+' >= :startDateRange';
                            }
                            if(dtWrp.endRange!=null ){
                                Date endDateRange = (Date)dtWrp.endRange; 
                                query+= ' and '+dtWrp.apiName+' <= :endDateRange';
                            }
                        }
                    }
                    if(filtFldWrapper.txtFiltFldWrapList!=null){
                        txtFilterFldWrapperList = filtFldWrapper.txtFiltFldWrapList;
                        for(txtFilterFldWrapper txtWrp:txtFilterFldWrapperList){
                            if(txtWrp.value != null && txtWrp.value != ''){
                                //query+= ' and '+txtWrp.apiName + ' ='+ '\''+txtWrp.value+'\'';
                                query+= ' and '+txtWrp.apiName + ' like '+ '\'%'+txtWrp.value+'%\'';
                            }
                            
                        }
                    }
                }
                query+=' order by '+nameField;
            }
            
            trans=Database.query(query);
        }
            //ConvertToWarpper:
	    // key = Headerfield, value: actual value
	     
            // Iterate over the object records
            for(SObject record : trans) {
                Map<String, Object> recordMap = new Map<String, Object>();
                List<String> fldList=queryFieldsString.split(','); //queried fields
                for (String fieldName : fldList) {
                    if (fieldName.contains('.')) {
                        // Extract the related object name and field name (e.g., 'ChannelPartner.Name' -> 'ChannelPartner' and 'Name')
                        List<String> fieldParts = fieldName.split('\\.');
                        String relatedObject = fieldParts[0];
                        String relatedField = fieldParts[1];
                        
                        // Access the related object dynamically using getSObject()
                        SObject relatedRecord = record.getSObject(relatedObject);
                        if (relatedRecord != null) {
                            // Get the related field dynamically using get()
                            recordMap.put(fieldName, relatedRecord.get(relatedField));
                        } else {
                            // If related record is null, set field as null
                            recordMap.put(fieldName, null);
                        }
                    } else {
                        // For standard fields, use get()
                        recordMap.put(fieldName, record.get(fieldName));
                    }
                    if(fieldName == 'Id' && recordMap.get(fieldName) != null && recordMap.containsKey(fieldName)){
                        if (lockedRecordIds.contains((Id)recordMap.get(fieldName))) {
                            recordMap.put('isRecordLockedInd', true);
                        }else{
                            recordMap.put('isRecordLockedInd', false);
                        }
                    }
                }
                res.add(recordMap);
            }

           
        
        }
         catch(Exception ex) {
           
            Core_MDF_CCP_UtilityClass.triggerErrLoggingPE(ex,'Critical',projectName,objectNm,'Mass Access Ownership Transfer',null);           
            throw new AuraHandledException(ex.getMessage());
        }
       return res;
        
    }
    //method to get touser
    @AuraEnabled
    public static List<SObjectResult> getToUser(String userName,String typeOfUser,Id toNodeAccId,Id intelAcc,Core_MDF_Custom_Utility_Config__c objConfigRec)
    {
        String projectName = objConfigRec.Core_MDF_App_nm__c;
        String objectName = objConfigRec.Core_MDF_Object_Label_nm__c;
        try{
        List<SObJectResult> sObjectResultList = new List<SObJectResult>();
        List<String> perm=new List<String>();
        Set<Id> usrIdList = new Set<Id>();
        string searchText = '\'%' + String.escapeSingleQuotes(userName) +'%\'';
        String program = objConfigRec.Core_MDF_Program_nm__c!=null?objConfigRec.Core_MDF_Program_nm__c:null;
        String systemUser = objConfigRec.Core_MDF_System_User_Name_txt__c!=null?objConfigRec.Core_MDF_System_User_Name_txt__c:null;
        if(objConfigRec.Core_MDF_Int_PermisionSet_Names_txt__c !=null || objConfigRec.Core_MDF_Ext_PermissionSet_Names_txt__c!=null){
            String permissionset= typeOfUser=='Internal User'?String.valueOf(objConfigRec.Core_MDF_Int_PermisionSet_Names_txt__c):typeOfUser=='External User'?String.valueOf(objConfigRec.Core_MDF_Ext_PermissionSet_Names_txt__c):''; 
                perm=permissionset.split(',');
                Integer permLen = perm.size();
                String pset='(\''+String.join(perm,'\',\'')+'\')';
               
                
                    String query='select id,AssigneeId,Assignee.Name, Assignee.Email from PermissionSetAssignment where PermissionSet.Name in '+pset+' and Assignee.IsActive=true'+' and '+'('+'Assignee.Name like ';
                    query=query+ searchText.trim();
                    query = query+'or Assignee.email like '+searchText.trim()+')';
                    
                    for(PermissionSetAssignment userlist1 :Database.Query(query)) 
                    {
                        
                        usrIdList.add(userlist1.AssigneeId);
                    }
                    String usrIdListStr='(\''+String.join(usrIdList,'\',\'')+'\')';
                    Set<Id> existingUserIds = new Set<Id>();
                    Integer i;
                    if(typeOfUser=='Internal User'){
                        i=0;
                        String iupgmQuery = 'Select id,Core_MDF_User_id__c, Core_MDF_User_id__r.name,Core_MDF_User_id__r.email from Core_MDF_Int_Users_Partner_Geo_Mapping__c where Core_MDF_Active_Ind__c = true and Core_MDF_Account_id__c = '+'\''+ ((program == 'Retail Marketing Funds') ? toNodeAccId : intelAcc) +'\''+' and Core_MDF_User_id__c in '+usrIdListStr;
                        existingUserIds.clear(); 
                        for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm:Database.Query(iupgmQuery)){
                            if(!existingUserIds.contains(iupgm.Core_MDF_User_id__c)&&i<=10) {
                            sObjectResultList.add(new SObjectResult(iupgm.Core_MDF_User_id__r.name, iupgm.Core_MDF_User_id__c, iupgm.Core_MDF_User_id__r.email));
                                i++;
                                if(i==10){
                                    break;
                                }
                            }
                            existingUserIds.add(iupgm.Core_MDF_User_id__c);
                            
                        }
                    }
                    else if(typeOfUser=='External User'){
                        i=0;
                        existingUserIds.clear(); 
                        String pnumQuery = 'Select id,Core_MDF_User__c, Core_MDF_User__r.name,Core_MDF_User__r.email from Core_MDF_Partner_Node_User_Mapping__c where Core_MDF_Active_Ind__c = true and Core_MDF_Account__r.Core_MDF_Channel_Program__r.Name='+'\''+program+'\''+'and Core_MDF_Account__r.Core_MDF_Active_Ind__c = true and '+'Core_MDF_User__c in '+usrIdListStr;
                        for(Core_MDF_Partner_Node_User_Mapping__c pnum:Database.Query(pnumQuery)){
                            if(!existingUserIds.contains(pnum.Core_MDF_User__c)&&i<=10) {
                            sObjectResultList.add(new SObjectResult(pnum.Core_MDF_User__r.name, pnum.Core_MDF_User__c, pnum.Core_MDF_User__r.email));
                            i++;
                            if(i==10){
                                    break;
                            }
                            }
                            existingUserIds.add(pnum.Core_MDF_User__c);
                        }
                    }
                    else if(typeOfUser=='System User') {
                        if(systemUser!=null){
                          User usr=[select id,name from User where name=:systemUser];
                         sObjectResultList.add(new SObjectResult(usr.name, usr.Id, ''));
                        }  
            }            
              
                
        }
        else if(objConfigRec.Core_MDF_Profiles_nm__c!=null){
            List<String> profileList=objConfigRec.Core_MDF_Profiles_nm__c.split(',');
            String profileStr = '(\''+String.join(profileList,'\',\'')+'\')';
            String query='Select id,name,Email from user where isActive= true and Profile.name in '+profileStr+' and Name like';
            query=query+ searchText.trim()+' LIMIT 10';
            
            for(user userlist1 :Database.Query(query)) 
                {
                    sObjectResultList.add(new SObjectResult(userlist1.Name, userlist1.Id,userlist1.Email));
                }
           
        }
        return sObjectResultList;
        }
        catch(Exception ex) {
            Core_MDF_CCP_UtilityClass.triggerErrLoggingPE(ex,'Critical',projectName,objectName,'Mass Access Ownership Transfer',null); 
            throw new AuraHandledException(ex.getMessage());
        }
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
    public static OwnerUpdateWrapper updateOwner(List<id> selectedRowIds,Id toUser, String obj,Core_MDF_Custom_Utility_Config__c objConfigRec)
    {
        OwnerUpdateWrapper updatedWrapper = new OwnerUpdateWrapper();
        boolean res=false;
        Set<Id> rowIds =new Set<Id>();
        String projectName = objConfigRec.Core_MDF_App_nm__c;
        String objectNm = objConfigRec.Core_MDF_Object_Label_nm__c;
        List<Id> updatedRecIdList = new List<Id>();
        String objApiName = objConfigRec.Core_MDF_Object_apiName_nm__c;
        
        try
        {
            Integer batchSize = objConfigRec.Core_MDF_Batch_Size_nbr__c!=null?Integer.valueOf(objConfigRec.Core_MDF_Batch_Size_nbr__c):20;
            if(selectedRowIds.size() <= batchSize)
            {
            
                List<sObject> sObjectsToUpdate = new List<sObject>();
                String sQuery = 'SELECT Id,OwnerId FROM ' + obj + ' WHERE ' + ' Id IN : '+ 'selectedRowIds';
                List<sObject> scope = Database.Query(sQuery);
                for(sObject objDetail : scope){
                    objDetail.put('OwnerId', toUser);
                    sObjectsToUpdate.add(objDetail);
                }
                
                saveResWarpper saveRes = saveResult(sObjectsToUpdate);
                updatedRecIdList = saveRes.updatedRecIds;
                boolean isUpdated = saveRes.updatedRecIds!=null && updatedRecIdList.size()>0?true:false;
                if(isUpdated){
                    List<Object> updatedRecordList = getObjectTransactions(null,null,null,null,null,null,null,objConfigRec,updatedRecIdList);
                    updatedWrapper.updatedRecordsList = updatedRecordList;
                }
                updatedWrapper.res = isUpdated;
                updatedWrapper.failedRecCount=saveRes.failedRecCount;
                if(updatedWrapper.failedRecCount>0 && saveRes.errorMsg!=''){
                    throw new DmlException(saveRes.errorMsg);
                }
            }   
            else {
                //create a log with chunk size and that list of records should be passed to batch

                //Roshan - insert log records
                List<Core_MDF_Batch_Request_and_Update_Log__c> logRecordstoInsert = new List<Core_MDF_Batch_Request_and_Update_Log__c>();
                Id recordTypeId = Schema.SObjectType.Core_MDF_Batch_Request_and_Update_Log__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Mass_Owner_Update').getRecordTypeId();
                            
                for (Id recId : selectedRowIds) {
                    Map<String, String> jsonMap = new Map<String, String>{'Id' => recId, 'OwnerId' => toUser};
                            
                    logRecordstoInsert.add(new Core_MDF_Batch_Request_and_Update_Log__c(
                        RecordTypeId = recordTypeId,
                        Core_MDF_Object_apiName_nm__c = objApiName,
                        Core_MDF_Record_Ids_Id__c = recId,
                        Core_MDF_JSON_String_txt__c = JSON.serialize(jsonMap),
                        Core_MDF_Action_txt__c = 'Update',
                        Core_MDF_Status__c = 'Pending'
                    ));
                }
                insert logRecordstoInsert;

                List<Id> logRecordIds = new List<Id>();
                for(Core_MDF_Batch_Request_and_Update_Log__c logRec : logRecordstoInsert) {
                    logRecordIds.add(logRec.Id);
                }

                List<Object> updatedRecordList = getObjectTransactions(null,null,null,null,null,null,null,objConfigRec,selectedRowIds);

                //Roshan - calling the batch
                Id batchInstanceId = Database.executeBatch(new Core_MDF_BatchRequestUpdateLog(logRecordIds, recordTypeId, objApiName, 'Update', null), batchSize);
		//Backup - Id batchInstanceId = Database.executeBatch(new Core_MDF_Batch_MassOwnerUpdate(logRecordIds, recordTypeId, objApiName), 50);


                updatedWrapper.isBatchExecution = true;
            }
    
        }
        catch(Exception ex) {
            updatedWrapper.isError=true;
            Core_MDF_CCP_UtilityClass.triggerErrLoggingPE(ex,'Critical',projectName,objectNm,'Mass Access Ownership Transfer',null); 
            
        }
        return updatedWrapper;
    }
  
    public static saveResWarpper saveResult(List<sobject> sObjectsToUpdate){
        saveResWarpper saveRes = new saveResWarpper();
        
        List<Id> updatedRecIds = new List<Id>();
        integer failedRecCount = 0;
        try{
        Database.saveResult[] saveList = Database.update(sObjectsToUpdate,false);
        
        String errs = '';
        for(Database.saveResult sr : saveList) {
            if(sr.isSuccess()){
               
                updatedRecIds.add(sr.getId());
                saveRes.updatedRecIds = updatedRecIds;

            } else {
                if (!sr.isSuccess()) {  
                    for(Database.Error err : sr.getErrors()) {  
                        failedRecCount++;
                        
                        errs += err.getMessage() + ' - ' + sr.getId()+',\n';
                    }
                    saveRes.failedRecCount = failedRecCount;
                }
            }
        }
        if(errs!=''){
            saveRes.errorMsg=errs;
        }
       
        }
        catch(Exception ex) {
            throw ex;
            
        }
        return saveRes;
        
    }


    @AuraEnabled(cacheable=true)
    public static List<SObject> UserReports( Id FromUser,Id ToUser){
        List<SObject> lObjRe = new List<SObject>();
        try{
        List<Id> SendRepID = new List<Id>();
        List<Report> SendRep = new List<Report>();
        Map<String,Set<Report>> refolsetIdMap = new Map<String,Set<Report>>();
        Map<Id,String> foldNmIdmap = new Map<Id,String>();
        Set<Id> usAcReId = new Set<Id>();
        set<Id>FinalReId = new Set<Id>();
        
        set<Report>FinalReport = new Set<Report>(); 
        List<Report> frUsRep= [SELECT Id,Name, FolderName, CreatedDate,CreatedBy.Name,CreatedBy.IsActive,CreatedBy.Profile.Name,OwnerId,LastRunDate  FROM Report where CreatedById =: FromUser ];
        if(!frUsRep.isEmpty()){
            for( Report Repot: frUsRep){
                if(Repot.FolderName != 'Public Reports'){
                    set<Report> rept = new Set<Report>();
                    if(refolsetIdMap.containsKey(Repot.FolderName)){
                        rept = refolsetIdMap.get(Repot.FolderName);
                    }
                    rept.add(Repot);
                    refolsetIdMap.put(Repot.FolderName,rept);
                }
            }
        }
        if(refolsetIdMap != null){
            for(folder FolDevelName : [SELECT Id,Name from folder where name IN: refolsetIdMap.keySet() and Type='Report']){
                foldNmIdmap.put(FolDevelName.Id , FolDevelName.Name);
            }
        }
        if(foldNmIdmap != null){
            for(UserRecordAccess usReAcc : [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE RecordId IN: foldNmIdmap.keySet() AND UserId =: ToUser  ]){
                if(usReAcc.HasReadAccess == false){
                    usAcReId.add(usReAcc.RecordId);
                }
            }
        }
        if(!usAcReId.isEmpty()){
            for(Id uaId: usAcReId){
                if(foldNmIdmap.containsKey(uaId)){
                    FinalReport.addAll(refolsetIdMap.get(foldNmIdmap.get(uaId)));
                }
            }
        }
        SendRep.addAll(FinalReport);
        lObjRe = SendRep;
        }
        catch(Exception ex) {
            Core_MDF_CCP_UtilityClass.triggerErrLoggingPE(ex,'Critical','CRM','Report','Mass Access Ownership Transfer',null); 
            throw new AuraHandledException(ex.getMessage());
            
        }
        return lObjRe;

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
        public Map<String,List<Core_MDF_Custom_Utility_Config__c>> mdtList {get; set;} //convert to Map<String,List<Core_MDF_Custom_Utility_Config__c>> - > Key = App or App+Program
        @AuraEnabled
        public Map<String,List<DropDownWrapper>> appWithProgramList{get;set;}
    }
    public class OwnerUpdateWrapper {
        @AuraEnabled
        public boolean res {get;set;}
        @AuraEnabled
        public List<Object> updatedRecordsList {get;set;}
        @AuraEnabled
        public boolean isError {get;set;}
        @AuraEnabled
        public integer failedRecCount {get;set;}
        @AuraEnabled
        public boolean isBatchExecution {get;set;}
        
    }
    public class saveResWarpper {
        public integer failedRecCount {get; set;}
        public List<Id> updatedRecIds {get; set;}
        public String errorMsg {get;set;}
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
    public class picklistFilterFldWrapper{
        @AuraEnabled public String apiName { get; set; }
        @AuraEnabled public List<String> value { get; set; }
    }
    public class dtFilterFldWrapper{
        @AuraEnabled public String apiName { get; set; }
        @AuraEnabled public Date startRange { get; set; }
        @AuraEnabled public Date endRange { get; set; }
    }
    public class txtFilterFldWrapper{
        @AuraEnabled public String apiName { get; set; }
        @AuraEnabled public String value { get; set; }
       
    }
   
    public class FilterFieldsWrapper{
        @AuraEnabled public List<picklistFilterFldWrapper> picklistFiltFldWrapList { get; set; }
        @AuraEnabled public List<dtFilterFldWrapper> dtFiltFldWrapList  { get; set; }
        @AuraEnabled public List<txtFilterFldWrapper> txtFiltFldWrapList  { get; set; }
       
    }
    
}