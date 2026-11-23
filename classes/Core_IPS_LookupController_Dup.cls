/***************************************************************************************************
Class Name:  Core_IPS_LookupController_Dup
Class Type: LookUp Class 
Version     : 1.0 
Created Date: 14 Oct 2015
Function    : This class contains custom lookup and related cross logic functionality. 
Input Parameters: None 
Output Parameters: None
Description:   Used in case edit page to get the case lookup results.
Used in     : Case Creation/Update
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Jayaprakash T              10/14/2015              Created
* Abhishek Arya              Nov/05/2015             Modified
****************************************************************************************************/ 
public  class Core_IPS_LookupController_Dup
{
    public String query {get; set;}
    public String HandledQueryParam{get; set;}
    public List<Account> accounts {get; set;}
    public List<Contact> contactList {get;set;}
    public List<Contact> conList{get;set;}
    public String objectName{get;set;}
    public String relatedId{get;set;}
    public String relatedId2{get;set;}
    public List<Core_IPS_Project__C> projList{get;set;}
    public List<Asset> prodList{get;set;}
    public List<Core_IPS_Supported_Product__c> productList{get;set;}
    public boolean displayContacts{get;set;}
    public boolean displayProjects{get;set;}
    public boolean displayProducts{get;set;}
    public boolean displaySAProducts{get;set;}
    public boolean displayCustProds{get;set;}
    public List<Asset> custProdList{get;set;}
    public boolean displaySuppAccount{get;set;}
    public List<Account> suppAccount{get;set;}
    
    public String contId{get;set;}
    
    public string name{get;set;}
    //public string testString{get;set;}
    public list<SelectOption> AnswerOptions{get;set;}
    
    public Core_IPS_LookupController_Dup(){
        //
        name = ApexPages.currentPage().getParameters().get('queryParam');
        objectName = ApexPages.currentPage().getParameters().get('object');
        relatedId = ApexPages.currentPage().getParameters().get('relatedId');
        relatedId2 = ApexPages.currentPage().getParameters().get('relatedId2');
    }
    
    public void pageLoad(){
        if(name!=null && name!=''){
            query=name;
            getRecords();
        }
    }
    
/***************************************************************************************************
Method Name:  getRecords 
Version     : 1.0 
Created Date: 14 Oct 2015
Function    : This method checks and decide which custom lookup and related cross logic functionality should be executed. 
Input Parameters: None 
Output Parameters: Null
Description:   Used in case edit page to get the case lookup results.
Used in     : Case Creation/Update
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Jayaprakash T              10/14/2015              Created
* Abhishek Arya              Nov/05/2015             Modified
****************************************************************************************************/
    public PageReference getRecords(){
        List<String> projIdList = new List<String>();
        System.debug('objectName:'+objectName);
        System.debug('relatedId:'+relatedId);
        System.debug('Query=====    '+query);
        HandledQueryParam = Core_Utility.SOSLQueryStringValidator(query);
        System.debug('HandledQueryParam=====    '+HandledQueryParam);
        if(relatedId!=null && relatedId!=''){
            system.debug('@@@@@@@@0@@@@@@@@@@@@'+relatedId);
             List<user> faeUsers = new List<User>();
            List<user> u = new List<User>();
            System.debug('Related Id:'+relatedId);
            if(relatedId.startswith('003'))
                u = [select id from user where contactId=:relatedId];
            else
                faeUsers = [select id from user where ID=:UserInfo.getUserId()];
            //
            List<Core_ips_Project__Share> projMembers;
            if((objectName=='project' || objectName=='product') && faeUsers <> null && faeUsers.size() > 0){
                projMembers = [select parentid from Core_ips_Project__share where userorgroupId =:faeUsers[0].id and parent.core_status__c='Active'];  
                if(projMembers <> null && projMembers.size() > 0){
                    for(Core_ips_Project__share member: projMembers){
                        if(member.parentid!=null){
                            projIdList.add(member.parentid);
                        }   
                    }
                }
            }
            system.debug('@@@@@@@@1@@@@@@@@@@@@'+projIdList);
            if((objectName=='project' || objectName=='product') && u <> null && u.size() > 0){                
                projMembers = [select parentid from Core_ips_Project__share where parent.core_status__c='Active' AND userorgroupId in (SELECT groupid FROM GroupMember where userorgroupid=:u[0].id)];   
                if(projMembers <> null && projMembers.size() > 0){
                    for(Core_ips_Project__share member: projMembers){
                        if(member.parentid!=null){
                            //projIdList.add('\''+member.parentid+'\'');
                            projIdList.add(member.parentid);
                        }   
                    }
                }
            }
            system.debug('@@@@@@@@2@@@@@@@@@@@@'+projIdList);               
        }            
        if(objectName=='Contact'){
            system.debug('@@@@@@@@Contact@@@@@@@@@@@@');
            contactLookup();
        }else if(objectName=='Project'){
            system.debug('@@@@@@@@Project@@@@@@@@@@@@');
            projectLookup(projIdList);
        }else if(objectName=='Product'){
            system.debug('@@@@@@@@Product@@@@@@@@@@@@');
            productLookup(projIdList);            
        }else if(objectName=='CustProd'){
            system.debug('@@@@@@@@CustProd@@@@@@@@@@@@');
            custProdLookup();
        }else if(objectName=='Account'){
            system.debug('@@@@@@@@Account@@@@@@@@@@@@');
            getLookupAccount();
        }
        else{
            displayContacts=false;
            displayProjects=false;
            displayProducts=false;
            displaySAProducts =true;
            displayCustProds = false;
            displaySuppAccount = false;
            List<List <sObject>> searchList;
            String queryString = '';
            String soslQuery = '';
            if(query==''){
                queryString = 'SELECT ';
                List<Schema.FieldSetMember> fieldSetMemberList =  Core_Utility.readFieldSet('SupportedProductFieldSet','Core_IPS_Supported_Product__c');
                for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
                    queryString += fieldSetMemberObj.getFieldPath() + ', ';
                }
                queryString += 'Id FROM Core_IPS_Supported_Product__c where Core_EOIS__c != True ORDER BY Core_Product__r.Name ASC limit 300';
                productList = Database.query(queryString); 
            }else if(query.trim().length()>1){
                soslQuery = 'find {*'+HandledQueryParam+'*} IN ALL FIELDS RETURNING Core_IPS_Supported_Product__c (';
                List<Schema.FieldSetMember> fieldSetMemberList =  Core_Utility.readFieldSet('SupportedProductFieldSet','Core_IPS_Supported_Product__c');
                for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
                    soslQuery += fieldSetMemberObj.getFieldPath() + ', ';
                }
                soslQuery += 'id where Core_EOIS__c != True ORDER BY Core_Product__r.Name ASC) ';
                searchList = search.query(soslQuery);
                productList = ((List<Core_IPS_Supported_Product__c>)searchList[0]);
               
            }
            else{
                 apexPages.addmessage(new apexpages.message(apexpages.severity.Error, 'Please enter at least two characters..'));
                return null;
            }
        }
        return null;
    }    

/***************************************************************************************************
Method Name:  contactLookup 
Version     : 1.0 
Created Date: Nov 05 2015
Function    : This method handles the contact custom lookup and related cross logic functionality. 
Input Parameters: None 
Output Parameters: Null
Description:   Used in case edit page to get the case related Contact lookup results.
Used in     : Case Creation/Update
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Abhishek Arya              Nov/05/2015             Created
****************************************************************************************************/
    
    public PageReference contactLookup(){
        displayContacts=true;
        displayProjects=false;
        displayProducts=false;
        displaySAProducts =false;
        displayCustProds = false;
        displaySuppAccount = false;
        List<Id> cIdList = new List<Id>();
        List<List <sObject>> searchList;
        String queryString='';
        String soslQuery='';
        Set<Id> accountIdList = new Set<Id>();
        Boolean isSalesProfileUser = false;
        List<AccountTeamMember> atmList = [select UserId,AccountId from AccountTeamMember where UserId =:System.UserInfo.getUserId() AND User.Profile.Name in:Label.Core_IPS_Sales_Profile_List.split(',')];
        system.debug('####ATM####'+atmList);
        if(atmList <> null && atmList.size() > 0){
            //accountIdList = new List<Id>();
            for(AccountTeamMember atmObj:atmList){
                accountIdList.add(atmObj.AccountId);
            }
            isSalesProfileUser = true;
        }    
        Map<Id,Account> accMap = new Map<Id,Account>([Select Id from Account where OwnerId =:System.UserInfo.getUserId() AND Owner.Profile.Name in:Label.Core_IPS_Sales_Profile_List.split(',')]);
        if(accMap <> null && accMap.size() > 0){
            accountIdList.addAll(accMap.keyset());
        }
        List<Profile> prfName = [select Name from Profile where Id =:UserInfo.getProfileId()  and Profile.Name in:Label.Core_IPS_Sales_Profile_List.split(',')];
        if((prfName <> null && prfName.size() > 0) && (atmList == null || atmList.size() == 0)){        
            isSalesProfileUser = true; 
        }
        System.debug('####isSalesProfileUser####'+isSalesProfileUser);
        if(query==''){
            queryString = 'SELECT ';
            List<Schema.FieldSetMember>  fieldSetMemberList =  Core_Utility.readFieldSet('ContactFieldSet','Contact');
            for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
                queryString += fieldSetMemberObj.getFieldPath() + ', ';
            }
            if(accountIdList <> null && accountIdList.size() > 0)
                queryString += 'Id FROM Contact where Core_IPS_Active__c=true AND AccountId in:accountIdList';
            else if(isSalesProfileUser == false)
                queryString += 'Id FROM Contact where Core_IPS_Active__c=true';
            //System.debug('projIdList=== '+projIdList);
            if(relatedId!=null && relatedId!=''){                    
                    List<Core_IPS_Project_Member__c> cpmList = new List<Core_IPS_Project_Member__c>();
                    //List<String> cIdList = new List<String>();
                    cpmList = [select Core_IPS_Contact__c,Core_IPS_Project__c from Core_IPS_Project_Member__c where Core_IPS_Project__c =:relatedId and Core_Status__c = 'Active'];
                    if(cpmList <> null && cpmList.size() > 0){
                        for(Core_IPS_Project_Member__c cpmObj:cpmList){
                            if(cpmObj <> null && cpmObj.Core_IPS_Contact__c <> null)
                            cIdList.add(cpmObj.Core_IPS_Contact__c);
                        }
                        system.debug('#######'+cIdList);                                                                                    
                    }
                    queryString= queryString+ ' and id in: cIdList';
            system.debug('@@@@@@!!!!@@@@@@'+queryString+cIdList+relatedId);
            }                                
            else if(relatedId2 != null && relatedId2 != ''){                
                Asset astObj = [select Id,accountId,ContactId,Core_IPS_Project__c from Asset where Id =:relatedId2];
                if(astObj <> null && astObj.AccountId <> null){
                    List<Contact> contactList = [select Id from Contact where AccountId =: astObj.AccountId];
                    if(contactList <> null && contactList.size() > 0){
                        for(Contact conObj:contactList){
                            cIdList.add(conObj.Id);
                        }
                    }                                           
                }
                if(astObj <> null && astObj.Core_IPS_Project__c <> null){
                    List<Core_IPS_Project_Member__c> cpmList = new List<Core_IPS_Project_Member__c>();
                    cpmList = [select Core_IPS_Contact__c,Core_IPS_Project__c from Core_IPS_Project_Member__c where Core_IPS_Project__c =:astObj.Core_IPS_Project__c and Core_Status__c = 'Active'];
                    if(cpmList <> null && cpmList.size() > 0){
                        for(Core_IPS_Project_Member__c cpmObj:cpmList){
                            if(cpmObj <> null && cpmObj.Core_IPS_Contact__c <> null)
                            cIdList.add(cpmObj.Core_IPS_Contact__c);
                        }
                        system.debug('#######'+cIdList);                                                                                    
                    }                                           
                }
                queryString= queryString+ ' and (Id in: cIdList)';
                system.debug('@@@@@@!!!!@@@@@@'+queryString+cIdList+relatedId2);
            }                
            System.debug('Query is=======   '+queryString);
            queryString = queryString + ' LIMIT 300';
            if((accountIdList <> null && accountIdList.size() > 0) || (isSalesProfileUser == false))
            conList = Database.query(queryString);
        }else if(query.trim().length() > 1){
            soslQuery = 'find {*'+HandledQueryParam+'*} IN ALL FIELDS RETURNING CONTACT (';
            List<Schema.FieldSetMember> fieldSetMemberList = Core_Utility.readFieldSet('ContactFieldSet','Contact');
            for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
                soslQuery += fieldSetMemberObj.getFieldPath() + ', ';
            }
            //soslQuery += 'id where Core_IPS_Active__c=true';
            if(accountIdList <> null && accountIdList.size() > 0)
                soslQuery += 'id where Core_IPS_Active__c=true AND AccountId in:accountIdList';
            else if(isSalesProfileUser == false)
                soslQuery += 'id where Core_IPS_Active__c=true';
            
            system.debug('@@@@@@@@contact@@@@@@@@@@@@'+soslQuery);
            
            if(relatedId!=null && relatedId!=''){                    
                    List<Core_IPS_Project_Member__c> cpmList = new List<Core_IPS_Project_Member__c>();
                    cpmList = [select Core_IPS_Contact__c,Core_IPS_Project__c from Core_IPS_Project_Member__c where Core_IPS_Project__c =:relatedId and Core_Status__c = 'Active'];
                    if(cpmList <> null && cpmList.size() > 0){                            
                        for(Core_IPS_Project_Member__c cpmObj:cpmList){
                            if(cpmObj <> null && cpmObj.Core_IPS_Contact__c <> null)
                            cIdList.add(cpmObj.Core_IPS_Contact__c);
                        }                                                       
                    }                                                                    
                    soslQuery= soslQuery+ ' and id in: cIdList LIMIT 300)';
            system.debug('@@@@@@!!!!@@@@@@'+soslQuery+cIdList);
            }
            else if(relatedId2 != null && relatedId2 != ''){                
                Asset astObj = [select Id,accountId,ContactId,Core_IPS_Project__c from Asset where Id =:relatedId2];                    
                if(astObj <> null && astObj.AccountId <> null){
                    List<Contact> conList = [select Id from Contact where AccountId =: astObj.AccountId];
                    if(conList <> null && conList.size() > 0){
                        for(Contact conObj:conList){
                            cIdList.add(conObj.Id);
                        }
                    }                                          
                }
                if(astObj <> null && astObj.Core_IPS_Project__c <> null){
                    List<Core_IPS_Project_Member__c> cpmList = new List<Core_IPS_Project_Member__c>();
                    cpmList = [select Core_IPS_Contact__c,Core_IPS_Project__c from Core_IPS_Project_Member__c where Core_IPS_Project__c =:astObj.Core_IPS_Project__c and Core_Status__c = 'Active'];
                    if(cpmList <> null && cpmList.size() > 0){
                        for(Core_IPS_Project_Member__c cpmObj:cpmList){
                            if(cpmObj <> null && cpmObj.Core_IPS_Contact__c <> null)
                            cIdList.add(cpmObj.Core_IPS_Contact__c);
                        }
                        system.debug('#######'+cIdList);                                                                                    
                    }                                           
                }
                soslQuery= soslQuery+' and Id in: cIdList LIMIT 300)';
                system.debug('@@@@@@!!!!@@@@@@'+soslQuery+cIdList);
            }
            else{
                soslQuery= soslQuery+ ' LIMIT 300)';
            }                                                
            system.debug('@@@@@@@@contact@@@@@@@@@@@@'+soslQuery);
            if((accountIdList <> null && accountIdList.size() > 0) || (isSalesProfileUser == false)){
                searchList = search.query(soslQuery);   
                conList =    ((List<Contact>)searchList[0]);                
           }
       }else{
           apexPages.addmessage(new apexpages.message(apexpages.severity.Error, 'Please enter at least two characters..'));
           return null;
       }   
       return null; 
    }

/***************************************************************************************************
Method Name:  projectLookup 
Version     : 1.0 
Created Date: Nov 05 2015
Function    : This method handles the project custom lookup and related cross logic functionality. 
Input Parameters: List of Project Ids. 
Output Parameters: Null
Description:   Used in case edit page to get the case related Project lookup results.
Used in     : Case Creation/Update
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Abhishek Arya              Nov/05/2015             Created
****************************************************************************************************/
    
    public PageReference projectLookup(List<String> projIdList){
        displayContacts=false;
        displayProjects=true;
        displayProducts=false;
        displaySAProducts =false;
        displayCustProds = false;
        displaySuppAccount = false;
        List<List <sObject>> searchList;
        String queryString='';
        String soslQuery='';
        // Syed -- Start
        if(query==''){
            queryString = 'SELECT ';
            List<Schema.FieldSetMember>  fieldSetMemberList =  Core_Utility.readFieldSet('IpsProjectFieldSet','core_ips_project__c');
            for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
                queryString += fieldSetMemberObj.getFieldPath() + ', ';
            }
            queryString += 'Id FROM core_ips_project__c where core_status__c=\'Active\'';
            //projList = [select id,name from core_ips_project__c where core_status__c='Active'];
            System.debug('projIdList=== '+projIdList);
            if(relatedId!=null && relatedId!=''){
                queryString= queryString+' and id in: projIdList';
            }   
            if((relatedId2 != null && relatedId2 != '') && (relatedId == null || relatedId == '')){
                List<Asset> astList = [select Id,Core_IPS_Project__c from Asset where Id =:relatedId2];
                List<Id> prjIdList = new List<Id>();
                if(astList <> null && astList.size() > 0){
                    for(Asset astObj:astList){
                        if(astObj <> null && astObj.Core_IPS_Project__c <> null)
                        prjIdList.add(astObj.Core_IPS_Project__c);
                    }
                }
                //if(prjIdList <> null && prjIdList.size() > 0)
                queryString= queryString+' and id in: prjIdList';
            }
            System.debug('Query is=======   '+queryString);
            queryString = queryString + ' LIMIT 300'; 
            ProjList = Database.query(queryString);
        }else if(query.trim().length() > 1){
            soslQuery = 'find {*'+HandledQueryParam+'*} IN ALL FIELDS RETURNING core_ips_project__c (';
            List<Schema.FieldSetMember> fieldSetMemberList = Core_Utility.readFieldSet('IpsProjectFieldSet','core_ips_project__c');
            for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
                soslQuery += fieldSetMemberObj.getFieldPath() + ', ';
            }
            soslQuery += 'id where core_status__c=\'Active\'';
            if(relatedId!=null && relatedId!=''){
                //if(projIdList <> null && projIdList.size()>0){
                    soslQuery= soslQuery+ ' and id in: projIdList  LIMIT 300)';
                /*}else{
                    soslQuery= soslQuery+ ')';
                }*/
            }else if((relatedId2 != null && relatedId2 != '') && (relatedId == null || relatedId == '')){
                    List<Asset> astList = [select Id,Core_IPS_Project__c from Asset where Id =:relatedId2];
                    List<Id> prjIdList = new List<Id>();
                    if(astList <> null && astList.size() > 0){
                        for(Asset astObj:astList){
                            if(astObj <> null && astObj.Core_IPS_Project__c <> null)
                            prjIdList.add(astObj.Core_IPS_Project__c);
                        }
                    }
                    soslQuery= soslQuery+ ' and id in: prjIdList LIMIT 300)';                        
            }else{
                soslQuery= soslQuery+ ' LIMIT 300)';
            }
            System.debug('soslQuery=======  '+soslQuery);
            searchList = search.query(soslQuery);
            ProjList = ((List<core_ips_project__c>)searchList[0]);                
        }
        else{
            apexPages.addmessage(new apexpages.message(apexpages.severity.Error, 'Please enter at least two characters..'));
            return null;
        }           
        return null;
        // Syed -- End
    }


/***************************************************************************************************
Method Name:  productLookup 
Version     : 1.0 
Created Date: Nov 05 2015
Function    : This method handles the product custom lookup and related cross logic functionality. 
Input Parameters: List of Project Ids. 
Output Parameters: Null
Description:   Used in case edit page to get the case related Product lookup results.
Used in     : Case Creation/Update
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Abhishek Arya              Nov/05/2015             Created
****************************************************************************************************/
    
    public PageReference productLookup(List<String> projIdList){
        displayContacts=false;
        displayProjects=false;
        displayProducts=true;
        displaySAProducts =false;
        displayCustProds = false;
        displaySuppAccount = false;
        List<List <sObject>> searchList;
        String queryString='';
        String soslQuery='';
        // Syed -- Start
        //Stirng queryString='';
        if(query==''){
            queryString = 'SELECT ';
            List<Schema.FieldSetMember> fieldSetMemberList =  Core_Utility.readFieldSet('AssetFieldSet','asset');
            for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
                queryString += fieldSetMemberObj.getFieldPath() + ', ';
            }
            queryString += 'Id FROM asset where status!=\'Inactive\''; //Changed from Obsolete to Inactive by Roshan
            if(relatedId2!=null && relatedId2!=''){
                queryString +=' and core_ips_project__c =: relatedId2';
            }
            else if(relatedId!=null && relatedId!=''){
                Contact con= [Select id, accountId from contact where id=:relatedId limit 1];
                String contactId = con.Id;
                String accountId = con.accountId;
                if(contactId!=null && contactId.length()>0){
                    queryString += ' and ((contactId =: contactId';
                    if(accountId !=null && accountId !=''){
                        queryString +=' or accountId =: accountId)';
                    }
                    if(projIdList <> null && projIdList.size() > 0){
                        queryString +=' or Core_IPS_Project__c in: projIdList)';
                    }
                    else{
                        queryString +=')';
                    }
                }                                        
            }
            
            System.debug('Query String:'+queryString);
            queryString = queryString + ' ORDER BY Name ASC LIMIT 300';
            prodList = database.query(queryString);
        }else if(query.trim().length() > 1){
            soslQuery = 'find {*'+HandledQueryParam+'*} IN ALL FIELDS RETURNING asset (';
            List<Schema.FieldSetMember> fieldSetMemberList = Core_Utility.readFieldSet('AssetFieldSet','Asset');
            for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
                soslQuery += fieldSetMemberObj.getFieldPath() + ', ';
            }
            soslQuery += 'id where status!=\'Inactive\''; //Changed from Obsolete to Inactive by Roshan
            if(relatedId2!=null && relatedId2!=''){
                soslQuery= soslQuery+ ' and core_ips_project__c =: relatedId2 ORDER BY Name ASC LIMIT 300)';
            }
            else if(relatedId!=null && relatedId!=''){
                Contact con= [Select id, accountId from contact where id=:relatedId limit 1];
                String contactId = con.Id;
                String accountId = con.accountId;
                if(contactId!=null && contactId.length()>0){
                    soslQuery= soslQuery+ ' and ((contactId =: contactId';
                    if(accountId !=null && accountId !=''){
                        soslQuery= soslQuery+ ' or accountId =: accountId)';
                    }
                    if(projIdList <> null && projIdList.size() > 0){
                        soslQuery +=' or Core_IPS_Project__c in: projIdList))';
                    }
                    else{
                        soslQuery= soslQuery+'))';
                    }
                    
                }                                        
            }
            else{
                soslQuery= soslQuery+ ' ORDER BY Name ASC LIMIT 300)';
            }
            System.debug('soslQuery=======  '+soslQuery);
            searchList = search.query(soslQuery);
            prodList = ((List<asset>)searchList[0]);
        }
        else{
            apexPages.addmessage(new apexpages.message(apexpages.severity.Error, 'Please enter at least two characters..'));
            return null;
        }
        return null;
    }

/***************************************************************************************************
Method Name:  custProdLookup 
Version     : 1.0 
Created Date: Nov 05 2015
Function    : This method handles the product custom lookup and related cross logic functionality. 
Input Parameters: Nothing 
Output Parameters: Null
Description:   Used in case edit page to get the case related Product lookup results.
Used in     : Case Creation/Update
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Abhishek Arya              Nov/05/2015             Created
****************************************************************************************************/
    
    public PageReference custProdLookup(){
        displayContacts=false;
        displayProjects=false;
        displayProducts=false;
        displaySAProducts =false;
        displayCustProds = true;
        displaySuppAccount = false;
        List<Asset> assetList; 
        List<List <sObject>> searchList;
        String queryString='';
        String soslQuery='';
        if(query==''){
            queryString = 'SELECT ';
            List<Schema.FieldSetMember> fieldSetMemberList =  Core_Utility.readFieldSet('AssetFieldSet2','asset');
            for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
                queryString += fieldSetMemberObj.getFieldPath() + ', ';
            }
            queryString += 'Id FROM asset where status!=\'Inactive\''; //Changed from Obsolete to Inactive by Roshan
            if(relatedId!=null && (relatedId!='NA')){
                queryString += ' and core_ips_project__c =: relatedId';
            }else{
                queryString += ' and core_ips_project__c=null';
            }
            system.debug('@@@@@@@@custprod@@@@@@@@@@@@'+queryString);
            queryString = queryString + ' ORDER BY Name ASC LIMIT 300';
            custProdList = Database.query(queryString);
        }
        else if(query.trim().length()>1){
            soslQuery = 'find {*'+HandledQueryParam+'*} IN ALL FIELDS RETURNING asset (';
            List<Schema.FieldSetMember> fieldSetMemberList = Core_Utility.readFieldSet('AssetFieldSet2','Asset');
            for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
                soslQuery += fieldSetMemberObj.getFieldPath() + ', ';
            }
            soslQuery += 'id where status!=\'Inactive\''; //Changed from Obsolete to Inactive by Roshan
            system.debug('relatedid==>'+relatedId);
            if(relatedId!=null && relatedId!='NA' && relatedId!=''){
                soslQuery += ' and core_ips_project__c=: relatedId ORDER BY Name ASC LIMIT 300)';
            }else{
                soslQuery += ' and core_ips_project__c=null ORDER BY Name ASC LIMIT 300)';
                //soslQuery += ')';
            }
            System.debug('Query:'+soslQuery );
            searchList = search.query(soslQuery);
            custProdList = ((List<asset>)searchList[0]);
        }else{
            apexPages.addmessage(new apexpages.message(apexpages.severity.Error, 'Please enter at least two characters..'));
            return null;
        }
        return null;
    }
    
/***************************************************************************************************
Method Name:  getLookupAccount 
Version     : 1.0 
Created Date: Oct 27 2017
Function    : This method handles the Account lookup and related cross logic functionality. 
Input Parameters: Contact Id 
Output Parameters: Null
Description:   Used in case edit page to get the case related Partner Account lookup results.
Used in     : Case Creation/Update
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Geetha Arkadu             Oct/27/2017            Created
****************************************************************************************************/
    
            public List<Account> getLookupAccount(){
            displayContacts=false;
            displayProjects=false;
            displayProducts=false;
            displaySAProducts =false;
            displayCustProds = false;
            displaySuppAccount = true;
            
            
            User contIdVal = [select id,ContactId from user where id=:userinfo.getUserId() limit 1];
            String contId =contIdVal.ContactId;
            if(contIdVal.ContactId==null || contIdVal.ContactId==''){
            system.debug('Inside ==con');
                contId= apexpages.currentpage().getparameters().get('relatedId');
                String projId= apexpages.currentpage().getparameters().get('relatedId2');
            }
            system.debug('===relatedId==='+relatedId);
            system.debug('===relatedId2==='+relatedId2);
            //String contId = '0033F000002T9oEQAS';
           
            
            system.debug('==contId===='+contId);
           
            Contact c=[select id,name,accountid from contact where id=:contId];
            List<Core_IPS_Project_Member__c> projMembersList=[select id,name,Core_IPS_Project__c,Core_IPS_Contact_Account__c from Core_IPS_Project_Member__c where Core_IPS_Contact__c=:contId];  
            
            //prepare set for Core_IPS_Project__c
            
            Set<Id> projIds=new Set<Id>();
            for(integer i=0;i<projMembersList.size();i++){
                projIds.add(projMembersList[i].Core_IPS_Project__c);
            }
            if(relatedId2!=null && relatedId2!=''){
                projIds.clear();
                projIds.add(relatedId2);
                system.debug('projIds ::'+projIds);
            }
            system.debug('projMembersList'+projMembersList);
            system.debug('projIds'+projIds);
            
            List<Core_IPS_Account__c> projMemAccounts=[select id,name, Core_Account__r.id,Core_Account__c,Core_Account__r.Name,Core_IPS_Project__r.Name,Core_IPS_Project__c from Core_IPS_Account__c where Core_IPS_Project__c  IN :projIds];
            System.debug('projMemAccounts'+projMemAccounts);
            Set<Id> accIds=new set<Id>();
            for(integer i=0;i<projMemAccounts.size();i++){
            accIds.add(projMemAccounts[i].Core_Account__c);
            }
            accIds.add(c.accountid);
            system.debug('projMemAccounts'+projMemAccounts);
            system.debug('accIds'+accIds);
            list<account> acc=[select id,name from account where id in:accIds];
            system.debug('acc'+acc);
            
           suppAccount = acc;
            return acc;
} 
    
}