/***************************************************************************************************
Class Name:  Core_IPS_LookupController_DupProd
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
* Sugandha                   Dec/07/2017             Modified Iteration#-2 User story#-US72182 Description- added functionality for public product
* Sugandha                   Mar/06/2018             Modified Iteration#-8 User story#-US80381 Description- Product Lists/Look ups should be sorted by NDA/Non-NDA
****************************************************************************************************/ 
public with sharing class Core_IPS_LookupController_DupProd 
{
    public String dataTableJson {get;set;}
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
    public string name{get;set;}
    //public string testString{get;set;}
    public list<SelectOption> AnswerOptions{get;set;}
    //Iteration#-2 User story#-US72182 DeveloperName-Sugandha Description- added functionality for public product
    private String publicProductRecTypeName = Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_Global_Asset_RT'); //asset record type developer Name
    
    public Core_IPS_LookupController_DupProd(){
        //
        name = ApexPages.currentPage().getParameters().get('queryParam');
        objectName = ApexPages.currentPage().getParameters().get('object');
        relatedId = ApexPages.currentPage().getParameters().get('relatedId');
        relatedId2 = ApexPages.currentPage().getParameters().get('relatedId2');
        getRecords();
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
        }
        else{
        system.debug('@@@@@@@@elsepart@@@@@@@@@@@@');
            displayContacts=false;
            displayProjects=false;
            displayProducts=false;
            displaySAProducts =true;
            displayCustProds = false;
            List<List <sObject>> searchList;
            String queryString = '';
            String soslQuery = '';
            if(query==''){
                queryString = 'SELECT ';
                List<Schema.FieldSetMember> fieldSetMemberList =  Core_Utility.readFieldSet('SupportedProductFieldSet','Core_IPS_Supported_Product__c');
                for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
                    queryString += fieldSetMemberObj.getFieldPath() + ', ';
                }
                //queryString += 'Id FROM Core_IPS_Supported_Product__c where Core_EOIS__c != True ORDER BY Core_Product__r.Name ASC limit 300';
                //Iteration#-8 User story#-US80381 DeveloperName-Sugandha Description- Added Order By Core_IPS_Public_Product__c
                queryString += 'Id FROM Core_IPS_Supported_Product__c where Core_EOIS__c != True ORDER BY Core_IPS_Public_Product__c,Core_Product__r.Name ASC limit 300';
                productList = Database.query(queryString); 
            }else if(query.trim().length()>1){
                soslQuery = 'find {*'+HandledQueryParam+'*} IN ALL FIELDS RETURNING Core_IPS_Supported_Product__c (';
                List<Schema.FieldSetMember> fieldSetMemberList =  Core_Utility.readFieldSet('SupportedProductFieldSet','Core_IPS_Supported_Product__c');
                for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
                    soslQuery += fieldSetMemberObj.getFieldPath() + ', ';
                }
                //Iteration#-8 User story#-US80381 DeveloperName-Sugandha Description- Added Order By Core_IPS_Public_Product__c
                soslQuery += 'id where Core_EOIS__c != True ORDER BY Core_IPS_Public_Product__c,Core_Product__r.Name ASC LIMIT 300) '; //added LIMIT for DE36616 by amritesh 2/27/2018
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
* Sugandha                   Nov/16/2017             Modified Iteration#-2 User story#-US72182
****************************************************************************************************/
    
    public PageReference contactLookup(){
    
        system.debug('@@@@@@@@Contact@@@@@@@@@@@@');
        displayContacts=true;
        displayProjects=false;
        displayProducts=false;
        displaySAProducts =false;
        displayCustProds = false;
        List<Id> cIdList = new List<Id>();
        List<List <sObject>> searchList;
        String queryString='';
        String soslQuery='';
        Set<Id> accountIdList = new Set<Id>();
        Boolean isSalesProfileUser = false;
        if(query == null)
            query = '';
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
        if(query=='' && query!= null){
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
               
                Asset astObj = [select Id,accountId,ContactId,Core_IPS_Project__c ,Core_Supported_Product__r.Core_IPS_Public_Product__c from Asset where Id =:relatedId2];
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
                 //Iteration#-2 User story#-US72182 DeveloperName-Sugandha Description- added functionality for public product
                if(astObj <> null && astObj.Core_Supported_Product__r.Core_IPS_Public_Product__c == false) //&& astObj.Core_IPS_Project__c == null && astObj.AccountId == null)
                {
                    queryString= queryString+ ' and (Id in: cIdList)';
                }
                //end                
                system.debug('@@@@@@!!!!@@@@@@'+queryString+cIdList+relatedId2);
            }                
            System.debug('Query is=======   '+queryString);
            queryString = queryString + ' LIMIT 300';
            if((accountIdList <> null && accountIdList.size() > 0) || (isSalesProfileUser == false))
            conList = Database.query(queryString);
            dataTableJson = JSON.serialize(conList);
        }else if(query != null && query.trim().length() > 1 ){
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
                    //soslQuery= soslQuery+ ' and id in: cIdList)';
            system.debug('@@@@@@!!!!@@@@@@'+soslQuery+cIdList);
            }
            else if(relatedId2 != null && relatedId2 != ''){                
                Asset astObj = [select Id,accountId,ContactId,Core_IPS_Project__c,Core_Supported_Product__r.Core_IPS_Public_Product__c from Asset where Id =:relatedId2];                    
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
                //Iteration#-2 User story#-US72182 DeveloperName-Sugandha Description- added functionality for public product
                if(astObj <> null && astObj.Core_Supported_Product__r.Core_IPS_Public_Product__c == false) //&& astObj.Core_IPS_Project__c == null && astObj.AccountId == null)
                {
                    soslQuery= soslQuery+' and Id in: cIdList ';
                }    
                soslQuery= soslQuery+' LIMIT 300)';
                //soslQuery=soslQuery+' )';
                system.debug('@@@@@@!!!!@@@@@@'+soslQuery+cIdList);
            }
            else{
                soslQuery= soslQuery+ ' LIMIT 300)';
                //soslQuery= soslQuery+ ' )';
            }
            //end
            system.debug('@@@@@@@@contact@@@@@@@@@@@@'+soslQuery);
            if((accountIdList <> null && accountIdList.size() > 0) || (isSalesProfileUser == false)){
                searchList = search.query(soslQuery);   
                conList =    ((List<Contact>)searchList[0]);
                dataTableJson = JSON.serialize(conList);                
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
* Sugandha                   Nov/16/2017             Modified Iteration#-2 User story#-US72182        
****************************************************************************************************/
    
    public PageReference projectLookup(List<String> projIdList){
        displayContacts=false;
        displayProjects=true;
        displayProducts=false;
        displaySAProducts =false;
        displayCustProds = false;
        List<List <sObject>> searchList;
        String queryString='';
        String soslQuery='';
        if(query == null)
            query = '';
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
                List<Asset> astList = [select Id,Core_IPS_Project__c,Core_Supported_Product__r.Core_IPS_Public_Product__c from Asset where Id =:relatedId2 LIMIT 1];
                List<Id> prjIdList = new List<Id>();
                if(astList <> null && astList.size() > 0){
                    for(Asset astObj:astList){
                        if(astObj <> null && astObj.Core_IPS_Project__c <> null)
                        prjIdList.add(astObj.Core_IPS_Project__c);
                    }
                    
                    //Iteration#-2 User story#-US72182 DeveloperName-Sugandha Description- added functionality for public product 
                    if(astList <> null && astList[0].Core_Supported_Product__r.Core_IPS_Public_Product__c == false) //&& astObj.Core_IPS_Project__c == null && astObj.AccountId == null)
                    {
                        queryString= queryString+' and id in: prjIdList';
                    }
                }
                //if(prjIdList <> null && prjIdList.size() > 0)
               // queryString= queryString+' and id in: prjIdList';
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
                    List<Asset> astList = [select Id,Core_IPS_Project__c ,Core_Supported_Product__r.Core_IPS_Public_Product__c from Asset where Id =:relatedId2 LIMIT 1];
                    List<Id> prjIdList = new List<Id>();
                    if(astList <> null && astList.size() > 0){
                        for(Asset astObj:astList){
                            if(astObj <> null && astObj.Core_IPS_Project__c <> null)
                            prjIdList.add(astObj.Core_IPS_Project__c);
                        }
                        //Iteration#-2 User story#-US72182 DeveloperName-Sugandha Description- added functionality for public product
                        if(astList <> null && astList[0].Core_Supported_Product__r.Core_IPS_Public_Product__c == false) //&& astObj.Core_IPS_Project__c == null && astObj.AccountId == null)
                        {
                            soslQuery = soslQuery+ ' and id in: prjIdList';
                        }                        
                    }                
                    soslQuery= soslQuery+ ' LIMIT 300)';                        
            }else{
                soslQuery= soslQuery+ ' LIMIT 300)';
            }//end
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
* Sugandha                   Nov/16/2017             Modified Iteration#-2 User story#-US72182
****************************************************************************************************/
    
    public PageReference productLookup(List<String> projIdList){
    system.debug('@@@@@@@@prod1@@@@@@@@@@@@');
        displayContacts=false;
        displayProjects=false;
        displayProducts=true;
        displaySAProducts =false;
        displayCustProds = false;
        List<List <sObject>> searchList;
        String queryString='';
        String soslQuery='';
        if(query == null)
            query = '';
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
                    //queryString += ' and ((contactId =: contactId';
                    queryString += ' and (RecordType.DeveloperName=:publicProductRecTypeName or ((contactId =: contactId'; //changed
                    if(accountId !=null && accountId !=''){
                        queryString +=' or accountId =: accountId)';
                    }
                    if(projIdList <> null && projIdList.size() > 0){
                        queryString +=' or Core_IPS_Project__c in: projIdList)';
                    }
                    else{
                        queryString +=')';
                    }
                    queryString +=')'; //changed
                }                                        
            }
            
            System.debug('Query String:'+queryString);
            //Iteration#-2 User story#-US72182 DeveloperName-Sugandha Description- Added Order By Account.Name,Core_IPS_Project_Name__c 
            //Iteration#-8 User story#-US80381 DeveloperName-Sugandha Description- Added Order By Core_IPS_Support_License__c 
            queryString = queryString + ' ORDER BY Core_IPS_Support_License__c, Account.Name ASC NULLS Last, Core_IPS_Project_Name__c ASC NULLS Last,Name ASC LIMIT 300';
            prodList = database.query(queryString);
        }else if(query.trim().length() > 1){
            soslQuery = 'find {*'+HandledQueryParam+'*} IN ALL FIELDS RETURNING asset (';
            List<Schema.FieldSetMember> fieldSetMemberList = Core_Utility.readFieldSet('AssetFieldSet','Asset');
            for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
                soslQuery += fieldSetMemberObj.getFieldPath() + ', ';
            }
            soslQuery += 'id where status!=\'Inactive\''; //Changed from Obsolete to Inactive by Roshan
            if(relatedId2!=null && relatedId2!=''){
                //soslQuery= soslQuery+ ' and core_ips_project__c =: relatedId2 ORDER BY Name ASC  LIMIT 300)';
                //Iteration#-2 User story#-US72182 DeveloperName-Sugandha Description- Added Order By Account.Name,Core_IPS_Project_Name__c 
                //Iteration#-8 User story#-US80381 DeveloperName-Sugandha Description- Added Order By Core_IPS_Support_License__c 
                soslQuery= soslQuery+ ' and core_ips_project__c =: relatedId2 ORDER BY Core_IPS_Support_License__c ,Account.Name ASC NULLS Last, Core_IPS_Project_Name__c ASC NULLS Last,Name ASC LIMIT 300)';
            }
            else if(relatedId!=null && relatedId!=''){
                Contact con= [Select id, accountId from contact where id=:relatedId limit 1];
                String contactId = con.Id;
                String accountId = con.accountId;
                if(contactId!=null && contactId.length()>0){
                    //soslQuery= soslQuery+ ' and ((contactId =: contactId';
                    soslQuery += ' and (RecordType.DeveloperName=:publicProductRecTypeName or ((contactId =: contactId';
                    if(accountId !=null && accountId !=''){
                        soslQuery= soslQuery+ ' or accountId =: accountId)';
                    }
                    if(projIdList <> null && projIdList.size() > 0){
                        soslQuery +=' or Core_IPS_Project__c in: projIdList)';
                    }
                    else{
                        soslQuery= soslQuery+')';
                    }
                    soslQuery += '))';
                }                                        
            }
            else{
                //soslQuery= soslQuery+ ' ORDER BY Name ASC LIMIT 300)';
                //Iteration#-2 User story#-US72182 DeveloperName-Sugandha Description- Added Order By Account.Name,Core_IPS_Project_Name__c 
                //Iteration#-8 User story#-US80381 DeveloperName-Sugandha Description- Added Order By Core_IPS_Support_License__c 
                soslQuery= soslQuery+ 'ORDER BY Core_IPS_Support_License__c, Account.Name ASC NULLS Last, Core_IPS_Project_Name__c ASC NULLS Last,Name ASC LIMIT 300)';
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
    system.debug('@@@@@@@@prod2@@@@@@@@@@@@');
        displayContacts=false;
        displayProjects=false;
        displayProducts=false;
        displaySAProducts =false;
        displayCustProds = true;
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
}