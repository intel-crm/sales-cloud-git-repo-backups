public class Core_IPS_IP_Test {
    @auraenabled
    public static void test (id CaseId ){
             Map<Id,InterestedPartyWrapper> existingIpByUserId;
     list<InterestedPartyWrapper>linkedPartiesList;
     List<Id> atmid = new List<Id>();
     boolean isEditable;
        Case CaseObj;
        Set<String> ProfileID = new Set<String>();
     String noAssignedContactCaseRecordType;
SET<ID> relatedUserIDs = new SET<ID>();
        try{
            List<Profile> ProfileLst = new List<Profile>();
            List<String> interestedPartiesList = new List<String>();
            Set<Id> toBeDeletedIps = new Set<Id>();//Ashutosh - US103988 - initialization
            //IPRecordSet = new list<IPWrapper>();
            boolean searchMadeInt = false;
            boolean showErrorMsg = false;
            
            if(CaseId != null){
                CaseObj = [Select id, RecordTypeId,AccountID,account.ownerid,ownerid, Core_IPS_Project_Case__c,Core_IPS_Private_Project__c from Case where ID =: CaseId];
            }           
             noAssignedContactCaseRecordType = Core_IPS_Helper_Utility.getIPSLabel('Case_RT_Name_IPS_NoAssignedContact');
            Id noAssignedContactCaseId = Core_IPS_Interested_Party_Int_Controller.getCaseRecordtypeIDByName(noAssignedContactCaseRecordType);
            List<Core_IPS_Case_Interested_Party__c> LinkedInternalParties = new List<Core_IPS_Case_Interested_Party__c>();
            linkedPartiesList = new List<InterestedPartyWrapper>();//Ashutosh - US103988
            existingIpByUserId = new Map<Id,InterestedPartyWrapper>();//Ashutosh - US103988
            
            /*Ashutosh - 20/04/2018 -  US103988 - Adding "Type" check on interesetd party soql to get only internal parties*/
            LinkedInternalParties = [Select ID, Contact__c, First_Name__c, Email__c, Last_Name__c, User__c, Active__c from Core_IPS_Case_Interested_Party__c WHERE Case__c =: CaseId AND Type__c = 'Internal'];                 
            
            /*Ashutosh - US103988 - 20/04/2018 - adding below block to populate values from wrapper*/
            if(LinkedInternalParties.size() > 0){
                for(Core_IPS_Case_Interested_Party__c CIPSCIPEXT : LinkedInternalParties){
                    if(CIPSCIPEXT.User__c != null){
                        relatedUserIDs.add(CIPSCIPEXT.User__c);
                    }                   
                    /*Mapping All esisting ips wrapper record by user id so that if same user record get deselected and selected again then we will check map and add the samerecord back to wrapper list and also remove the ip record id from ipsToBeDeleted set which will save deletion of the record */
                    InterestedPartyWrapper partyRecord = new InterestedPartyWrapper(CIPSCIPEXT.User__c,CIPSCIPEXT.First_Name__c,CIPSCIPEXT.Last_Name__c,CIPSCIPEXT.Email__c,CIPSCIPEXT.Id,true);
                    linkedPartiesList.add(partyRecord);
                    system.debug('ListofLinkedparty'+linkedPartiesList);
                    if(existingIpByUserId.get(CIPSCIPEXT.User__c) == null){
                        existingIpByUserId.put(CIPSCIPEXT.User__c,partyRecord);
                    }
                }
            }   
            /**********************************************************************************************/
            
            interestedPartiesList = System.Label.Interested_Parties_Internal_Agent.split(';');//IPS Agent;IPS Agent Enhanced;Sales Rep-BB-Dual IPS;IPS Agent-Partner
            
            //Check if Loggedin User is IPS Agent and allow to search all Sales Reps irrespective of Case Account Team  -- 4/18/2017 Manoj Kumar
            for(String str : Label.Interested_Parties_Internal_Agent_ProfileIds.split(',')){  //All Agents profile IDs,Agent-Partner,SalesRep BB Dual IPS,IPS Support Org Admin 
                if(str == string.valueof(UserInfo.getProfileId())){
                    System.debug('-- Agent alike Users --');
                    interestedPartiesList.addall(new List<String>(Label.Core_IPS_FAE_ProfileName.split(';')));
                    break;
                }
            }// END Manoj Kumar            
            // added by sumukh for US176533              
            isEditable = [SELECT HasEditAccess,RecordId FROM UserRecordAccess WHERE UserId =:userinfo.getuserId() AND RecordId = :CaseId].HasEditAccess;
            
            if(isEditable == false) {
                showErrorMsg = true;
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,''+'You dont have sufficient access to add interested parties'));
                return ;
            }
            
            if(isEditable && CaseObj.RecordTypeId!=noAssignedContactCaseId ) {
                interestedPartiesList.addall(new List<String>(Label.Core_IPS_FAE_ProfileName.split(';')));                
            }            
            //End by sumukh for US176533                       
            //US176534 -- Gourav: To fetch all Sales Rep IDs for non-Project NAC cases
            if(CaseObj.RecordTypeId==noAssignedContactCaseId && (CaseObj.AccountId==null) && (CaseObj.Core_IPS_Project_Case__c==null) ){
                interestedPartiesList.addall(new List<String>(Label.Core_IPS_FAE_ProfileName.split(';'))); //All Sales profiles included
            }
            
            ProfileLst = [Select ID, Name from Profile Where (Name =: System.Label.Interested_Parties_Internal_Admin OR Name in: interestedPartiesList) AND (NOT(ID IN : relatedUserIDs))];           
            for(Profile P : ProfileLst){
                ProfileID.add(P.id); //Profile IDs of IPS Agent,Support Org Admin and all Sales profiles
            }                       
            String sQuery;
            
        } catch (exception ex){            
            System.debug('-- Exception Occured :'+ex.getMessage());
            System.debug('Error at line ' + ex.getStackTraceString());
        }
        
    }
        public class InterestedPartyWrapper{
        Id userId;
        public String firstName {get; set;}
        public String lastName {get; set;}
        public String email {get; set;}
        Id recordId;
        public Boolean isSelected{get;set;}
        
        public InterestedPartyWrapper(Id usrId ,String fname ,String lname ,String emailId , Id recId ,Boolean isChecked){
            userId = usrId;
            firstName = fname;
            lastName = lname;
            email = emailId;
            recordId = recId;
            isSelected = isChecked;
            
        }
    }

}