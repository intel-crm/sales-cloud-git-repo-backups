public class Core_IPS_Interested_Party_LEX {
    @AuraEnabled
    //created by ranjini
    public static wrapperClass getQueryResult(String queryString) {
        //variable declarations
        wrapperClass caseWrapper = new wrapperClass();
        List<sObject> sObjLst = new list<sObject>();
        List<Profile> ProfileLst = new List<Profile>();
        List<String> interestedPartiesList = new List<String>();//required in profile query
        boolean isEditable;
        String noAssignedContactCaseRecordType;
        noAssignedContactCaseRecordType = Core_IPS_Helper_Utility.getIPSLabel('Case_RT_Name_IPS_NoAssignedContact');
        Id noAssignedContactCaseId = getCaseRecordtypeIDByName(noAssignedContactCaseRecordType);
        Set<String> ProfileID = new Set<String>();
        SET<ID> relatedUserIDs = new SET<ID>();//required in profile quert
        
        
        sObjLst = Database.query(queryString);
        List<case> CaseObj = sObjLst;
        system.debug('-->sObjLst'+sObjLst[0].id);
        //check for Valid record type pending code
        List<Core_IPS_Case_Interested_Party__c> LinkedInternalParties = [Select ID, Contact__c, First_Name__c, Email__c, Last_Name__c, User__c, Active__c from Core_IPS_Case_Interested_Party__c WHERE Case__c =: sObjLst[0].id AND Type__c = 'Internal'];                 
        if(LinkedInternalParties.size() > 0){
            for(Core_IPS_Case_Interested_Party__c CIPSCIPEXT : LinkedInternalParties){
                if(CIPSCIPEXT.User__c != null){
                    relatedUserIDs.add(CIPSCIPEXT.User__c);
                }
            }
            //quesry on IP with same case and internal type
            LinkedInternalParties = [Select ID, Contact__c, First_Name__c, Email__c, Last_Name__c, User__c, Active__c from Core_IPS_Case_Interested_Party__c WHERE Case__c =:  sObjLst[0].id AND Type__c = 'Internal'];                 
            
            if(LinkedInternalParties.size() > 0){
                for(Core_IPS_Case_Interested_Party__c CIPSCIPEXT : LinkedInternalParties){
                    if(CIPSCIPEXT.User__c != null){
                        relatedUserIDs.add(CIPSCIPEXT.User__c);
                    }                   
                }
            } 
            //no data found
            interestedPartiesList = System.Label.Interested_Parties_Internal_Agent.split(';');//IPS Agent;IPS Agent Enhanced;Sales Rep-BB-Dual IPS;IPS Agent-Partner
            for(String str : Label.Interested_Parties_Internal_Agent_ProfileIds.split(',')){  //All Agents profile IDs,Agent-Partner,SalesRep BB Dual IPS,IPS Support Org Admin 
                if(str == string.valueof(UserInfo.getProfileId())){
                    System.debug('-- Agent alike Users --');
                    interestedPartiesList.addall(new List<String>(Label.Core_IPS_FAE_ProfileName.split(';')));
                    break;
                }
            }       
            isEditable = [SELECT HasEditAccess,RecordId FROM UserRecordAccess WHERE UserId =:userinfo.getuserId() AND RecordId = :sObjLst[0].id].HasEditAccess;
            //user doesnt have access quit the method
            if(isEditable == false) {
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,''+'You dont have sufficient access to add interested parties'));
                caseWrapper.success = false;
                return caseWrapper ;
            }
            
            //user has access
            /* if(isEditable && CaseObj[0].RecordTypeId!=noAssignedContactCaseId ) {
interestedPartiesList.addall(new List<String>(Label.Core_IPS_FAE_ProfileName.split(';')));                
}            
if(CaseObj[0].RecordTypeId==noAssignedContactCaseId && (CaseObj[0].AccountId==null) && (CaseObj[0].Core_IPS_Project_Case__c==null) ){
interestedPartiesList.addall(new List<String>(Label.Core_IPS_FAE_ProfileName.split(';'))); //All Sales profiles included
}

ProfileLst = [Select ID, Name from Profile Where (Name =: System.Label.Interested_Parties_Internal_Admin OR Name in: interestedPartiesList) AND (NOT(ID IN : relatedUserIDs))];           
for(Profile P : ProfileLst){
ProfileID.add(P.id); //Profile IDs of IPS Agent,Support Org Admin and all Sales profiles
}   */                    
        }   
        caseWrapper.success = true;caseWrapper.lstCase =sObjLst;
        return caseWrapper;
        
    }
    public static Schema.DescribeSObjectResult DescCase;  
    public static Map<id,Schema.RecordTypeInfo> MapCaseRecordTypeID ;
    public static Map<string,Schema.RecordTypeInfo> MapCaseRecordTypeName;    
    
    public static Id getCaseRecordtypeIDByName(string caseRecordtypeName)
    {
        system.debug('-->1'+caseRecordtypeName);
        Id  CaseRecordtypeID = null;
        if(DescCase==null)
        {
            DescCase = Schema.SObjectType.Case; 
        }
        if(MapCaseRecordTypeName ==  null)
        {
            MapCaseRecordTypeName = DescCase.getRecordTypeInfosByName();
        }       
        system.debug('-->'+caseRecordtypeName);
        CaseRecordtypeID = MapCaseRecordTypeName.get(caseRecordtypeName).getRecordTypeId();
        return CaseRecordtypeID;
    }
    
    public class wrapperClass{
        @AuraEnabled public List<case> lstCase{get;set;}
        @AuraEnabled public Boolean success{get;set;}
    }
    
    @AuraEnabled
    public static List<User> getUserDetailsBasedOnSearch(String searchValueUser, id caseid){
        System.debug('searchValueUser>>>'+searchValueUser);
        List<Profile> ProfileLst = new List<Profile>();
        Set<String> ProfileID = new Set<String>();
        List<String> interestedPartiesList = new List<String>();
        SET<ID> relatedUserIDs = new SET<ID>();
        interestedPartiesList = System.Label.Interested_Parties_Internal_Agent.split(';');
        
        //Check if Loggedin User is IPS Agent and allow to search all Sales Reps irrespective of Case Account Team  -- 4/18/2017 Manoj Kumar
        for(String str : Label.Interested_Parties_Internal_Agent_ProfileIds.split(',')){
            if(str == string.valueof(UserInfo.getProfileId())){
                System.debug('--IPS Agent User --');
                interestedPartiesList.addall(new List<String>(Label.Core_IPS_FAE_ProfileName.split(';')));
                break;
            }
        }
        ProfileLst = [Select ID, Name from Profile Where (Name =: System.Label.Interested_Parties_Internal_Admin OR Name in: interestedPartiesList) AND (NOT(ID IN : relatedUserIDs))];
        
        for(Profile P : ProfileLst){
            ProfileID.add(P.id);
        }
        List<User> UserList = new List<User>();
        List<User> UserListNew = new List<User>();
        List<Id> atmid = new List<Id>();
        
        case CaseObj = [Select id, AccountID,account.ownerid,ownerid, Core_IPS_Project_Case__c from Case where ID =:caseid ];
        Set<Id> SetAccountID = new Set<Id>();            
        SetAccountID.add(CaseObj.accountid);
        System.debug('--SetAccountID--'+SetAccountID);
        for(Set<id> SetID : Core_IPS_Helper_Utility.getFAEsByAccount(SetAccountID).values())
        {
            atmid.addall(SetID);
            if(SetID.contains(UserInfo.getUserId())){
                System.debug('--Loggedin User is part of Case Account Team --');
                for(String profId : label.Core_IPS_Sales_Rep_ProfileIds.split(',')){
                    if(UserInfo.getProfileId() == profId ){
                        System.debug('--Loggedin User is SalesRep and part of Case Account Team --');
                        ProfileID.addall(new List<String>(label.Core_IPS_Sales_Rep_ProfileIds.split(',')));
                        break;
                    }
                }
            } 
        }
        System.debug('--ProfileID --'+ProfileID);
        atmid.add(CaseObj.account.ownerid); 
        atmid.add(CaseObj.ownerid); 
        
        String searchableString = searchValueUser + '%';
        
        String sQuery;
        //external IP
        sQuery = 'SELECT Id, Name, FirstName, LastName, Email ' + 
            'FROM User ' + 
            'WHERE (ProfileID IN :ProfileID AND (FirstName like :searchableString OR LastName like :searchableString OR Email like :searchableString) AND (NOT(ID IN :relatedUserIDs)) AND (IsActive = true)) OR (ID in :atmid AND (FirstName like :searchableString OR LastName like :searchableString OR Email like :searchableString) AND (NOT(ID IN : relatedUserIDs)) AND (IsActive = true)) ' + 
            'ORDER BY Id desc Limit '+System.Label.Core_IPS_Interested_Party_Limit;
        System.debug('sQuery'+sQuery);
        UserList = Database.query(sQuery);
        System.debug('UserList-->'+UserList);
        System.debug('UserListsize-->'+UserList.size());
        
        //checking for existing IP newly added
        list<id>userid = new list<id>();
        
        //get list of exiting IP
        List<Core_IPS_Case_Interested_Party__c>checkexistingsingleInt   = 
            [Select Id, User__c from Core_IPS_Case_Interested_Party__c where Case__c =: caseId ];
        system.debug('checkexistingsingleInt-->'+checkexistingsingleInt);
        system.debug('checkexistingsingleInt size-->'+checkexistingsingleInt.size());
        //get all the user id from existing IP
        for(Core_IPS_Case_Interested_Party__c u:checkexistingsingleInt){
            userid.add(u.User__c);
        }
        system.debug('usedid'+userid.size());    
        //exclude this from user list
        for(User u:UserList){
            if(userid.contains(u.id)){
                
            }else{
                UserListNew.add(u);
            }
        }
        //return UserList;
        system.debug('UserListNew-->'+UserListNew.size());
        
        return UserListNew;
    }
    

    @AuraEnabled
    public static String saveInternalInterestedParty(List<Id> userID, String caseId, String contactID ){
        system.debug('-->'+userID);
        system.debug('-->'+caseId);
        system.debug('-->'+contactID);
        
        List<Core_IPS_Case_Interested_Party__c> interestedPartiesToBeCreated = new List<Core_IPS_Case_Interested_Party__c>();
        String existcheck = '';
        if(contactID ==''){
            system.debug('-->entered Internal');
            for(Id u:userID){
                Core_IPS_Case_Interested_Party__c newRecord = new Core_IPS_Case_Interested_Party__c();
                newRecord.User__c = u; 
                newRecord.Case__c = caseId;
                newRecord.Type__c = 'Internal';
                newRecord.Active__c = true;
                interestedPartiesToBeCreated.add(newRecord);
            }
            /*List<Core_IPS_Case_Interested_Party__c>     checkexistingsingleInt   = [Select Id, User__c from Core_IPS_Case_Interested_Party__c where User__c = :userID and Case__c =: caseId ];
            System.debug('checkexistingsingle'+checkexistingsingleInt);
            if(checkexistingsingleInt.size() > 0 ){
                existcheck = 'existinguser';
            }else{*/
                if(interestedPartiesToBeCreated.size() > 0){
                    system.debug('-->interestedPartiesToBeCreated'+interestedPartiesToBeCreated);
                    insert interestedPartiesToBeCreated;
                    existcheck = 'newuser';
                }
                
           // }
        }
        else  if(contactID != null || contactID != ''){
            system.debug('-->contactID'+contactID);
            
            for(Id u:userID){
                Core_IPS_Case_Interested_Party__c newRecord = new Core_IPS_Case_Interested_Party__c();
                newRecord.Contact__c = contactID; 
                newRecord.Case__c = caseId;
                newRecord.Type__c = 'External';
                newRecord.Active__c = true;
                interestedPartiesToBeCreated.add(newRecord);
                system.debug('-->contactID'+contactID);
            }
            List<Core_IPS_Case_Interested_Party__c>     checkexistingsingle   = [Select Id, Contact__c from Core_IPS_Case_Interested_Party__c where Contact__c = :contactID and Case__c =: caseId ];
            System.debug('checkexistingsingle'+checkexistingsingle);
            if(checkexistingsingle.size() > 0 ){
                existcheck = 'existingcontact';
            }else{
                if(interestedPartiesToBeCreated.size() > 0){
                    insert interestedPartiesToBeCreated;
                    existcheck = 'newcontact';
                }
                
            }
            
        }
        
        
        
        
        Return existcheck;
    }   
    
    
}