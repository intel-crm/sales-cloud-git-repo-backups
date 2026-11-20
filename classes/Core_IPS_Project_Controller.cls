/************************************************************************************************
*Class Name:  Core_IPS_Project_Controller
*Version     : 1.0 
*Created Date: Apr 23 2018
*Description:  Controller for Core_addProjectAccounts Page 
*Modification Log :
* Developer                   Date                        Description
* ----------------------------------------------------------------------------------------------                 
* Sugandha                    23/04/2018              Modified(UserStory US89550 Iteration 10)
* Aparna                      15/6/2018               Modified for US104027 & US108704 -PSG Independent Release
************************************************************************************************/
global with sharing class  Core_IPS_Project_Controller{
    /*Modified by Aayushi 07-11-2017 US79852 & US80374*/
    global static List<IPSAccountWrapper> acctWrapperList{get;set;}
    public List<IPSMemberWrapper> contWrapperList{get;set;}
    public String projectId{get;set;}
    public List<core_ips_account__c> existingAccounts{get;set;}
    public boolean displayExistingAccounts{get;set;}
    public List<SelectOption> participantTypes{get;set;}
    //public boolean displayAddSection{get;set;}            //commented by Aayushi US80368
    public List<Core_IPS_Project_Member__c> existingMembers{get;set;}
    public boolean displayExistingMembers{get;set;} public boolean displayAddMemberSection{get;set;}
    public core_ips_project__c project{get;set;}
    public boolean displayErrorSection{get;set;}
    public boolean errorMessage{get;set;}
    public String errorMsg{get;set;}
    public String strAccountInfo{get;set;}
    public String strAccountMembersInfo{get;set;} //START--US964686-- 30/4/2021 -- Rekha -- new variable to fetch the members value
    public boolean alreadySubmitted{get;set;}
    public String status=null;
    public String mpndaErrorMsg=null; 
    public String nonNDAErrorMsg=null;           //modified by Aayushi US95034
    public Static boolean checkCodeChange=false;
    public boolean isPrivateProject = false;
    

    @TestVisible global class IPSAccountWrapper{
        public account acc{get;set;}
        public boolean selected{get;set;}
        public List<SelectOption> participants{get;set;}
        public String participantTypeSelected{get;set;}
        //Added for US104027 by Aparna
        public string ownrname{get;set;} 
        public string unifiedID{get;set;}
        public string cimID{get;set;}
        public string accntID{get;set;} //Added by Aparna for US108704-PSG Independent Release
        //end
    }
   
    @TestVisible public class IPSMemberWrapper{
        public contact con{get;set;}
        public boolean selected{get;set;}
        public User usr{get;set;} 
    }
    
    public core_ips_project_controller(){
        
        if(!String.isBlank(ApexPages.currentPage().getParameters().get('projectId'))){
            // Unencoded Formulas in Script Tags XSS Fix - TWC745-7251
            projectId= ApexPages.currentPage().getParameters().get('projectId')?.escapeHtml4();
            //projectId= String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('projectId'));//pramodh

        }        
        //Set<Id> existingAccountIdSet = getExistingIPSAccountIds();
        participantTypes = getParticipantTypes();
        //acctWrapperList = new List<IPSAccountWrapper>();
        //acctWrapperList = getAccountsWrapper(existingAccountIdSet,participantTypes);
        /*added by Aayushi 07-11-2017 US79852*/
        Core_IPS_Labels__c ipsLabels = Core_IPS_Labels__c.getValues('CoreStatus_Draft');
        status=IpsLabels.Value__c;
        /*added by Aayushi 07-11-2017 US80374*/
        Core_IPS_Labels__c ipsLabelsMPNDA = Core_IPS_Labels__c.getValues('Core_IPS_MPNDA_ErrorMsg');
        mpndaErrorMsg=IpsLabelsMPNDA.Value__c;
        //added by Aayushi 02-23-2018 US80368
        Core_IPS_Labels__c ipsLabelsnonNDA = Core_IPS_Labels__c.getValues('Core_IPS_NonNDA_ErrorMSg');
        nonNDAErrorMsg=IpsLabelsnonNDA.Value__c;
        //Set<Id> existingConIdSet = getExistingIPSContIds(); //commented by amritesh 11/12/2017 - US80097
        contWrapperList = new List<IPSMemberWrapper>();
        //contWrapperList = getContactsWrapper(existingConIdSet);  //commented by amritesh 11/12/2017 - US80097 
        throwPageException();
        
    }
    
/*START*/    
// Code for submitting IPS Proj Products for Approval and changing the Status to Submitted-Pending.
    public core_ips_project_controller(ApexPages.standardController controller){
        projectId = controller.getId();
        //FLS Check Added - Yasasvi
        if(core_ips_project__c.SObjectType.getDescribe().isAccessible()){
            project = [select id, Name, core_status__c, Core_Number_of_Accounts__c, Core_Number_of_Products__c,Core_Number_of_Users__c, (Select id,Status__c,Core_IPS_IsAutoApprove__c, Core_Supported_Product__c, Core_Supported_Product__r.Core_Flag_Status__c, Core_IPS_Project__c,Core_IsSubmitted_Header__c from IPS_Products__r) from core_ips_project__c where id=:controller.getId()];        
        }
        /*added by Aayushi 07-11-2017 US79852*/
        Core_IPS_Labels__c ipsLabels = Core_IPS_Labels__c.getValues('CoreStatus_Draft');
        status=IpsLabels.Value__c;
        /*added by Aayushi 07-11-2017 US80374*/
        Core_IPS_Labels__c ipsLabelsMPNDA = Core_IPS_Labels__c.getValues('Core_IPS_MPNDA_ErrorMsg');
        mpndaErrorMsg=IpsLabelsMPNDA.Value__c;
    }
    
    public PageReference changeStatusToSubmitted(){

        if(project.core_status__c=='Submitted Pending' || project.core_status__c=='Active'){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Project is already Submitted. Do not try to Re-Submit. Refer to the Project Status value before Submitting'));
            return null;
        }
        /*Modified by Aayushi 2-11-17 US79852*/
        if(project.core_status__c==status && (project.Core_Number_of_Accounts__c == 0 || project.Core_Number_of_Products__c ==0 || project.Core_Number_of_Users__c == 0)){
              ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Project cannot be submitted without atleast one account and one Product and one Project Member'));
              return null;
        }
        

            AlreadySubmitted = false;
            if (Schema.sObjectType.core_ips_project__c.fields.core_status__c.isUpdateable()) {
                project.core_status__c = 'Submitted Pending';
            }
            update project;
        
        /*START*/ 
        //added by Roshan
        List<Core_IPS_Product__c> updateIPSProductList = new List<Core_IPS_Product__c>();
            for(Core_IPS_Product__c iPSProductRecord: project.IPS_Products__r){
                IPSProductRecord.Core_IsSubmitted_Header__c = true;
                if(IPSProductRecord.Core_Supported_Product__r.Core_Flag_Status__c == 'Auto Approve'){
                    IPSProductRecord.Core_IPS_IsAutoApprove__c = true;
                    IPSProductRecord.Status__c = 'Auto Approve';
                }   
                UpdateIPSProductList.add(IPSProductRecord);
            }        
        update UpdateIPSProductList;       
        /*END*/
        return new PageReference('/'+projectId);
    }

/*END*/    

    /* commented by amritesh 11/12/2017 - US80097
    @TestVisible private List<IPSMemberWrapper> getContactsWrapper(Set<Id> existingConIdSet){
       List<IPSMemberWrapper> wrapperInContext = new List<IPSMemberWrapper>(); 
       List<Core_ips_account__c> ipsAcctList = new List<core_ips_account__c>();
       ipsAcctList = getSelectiveAccounts(projectId);
       Set<Id> selActSet = new Set<Id>();
       for(Core_ips_account__c ipsAct:ipsAcctList){
           selActSet.add(ipsAct.core_account__c);
       }
       List<contact> contList;
       List<User> UserList;
       
       if(existingConIdSet!=null && existingConIdSet.size()>0)
           contList = [select id, firstName, lastName,account.name from contact where Core_IPS_Active__c = true and accountId in :selActSet and id not in :existingConIdSet];
       else
           contList = [select id, firstName, lastName, account.name from contact where Core_IPS_Active__c = true and accountId in :selActSet];
        
       if(contList <> null && contList.size()>0)
       UserList = new List<User>([Select id, contactid from User where Contactid IN:contList  and IsActive =true]);
        //added by amritesh 11/12/2017 - US80097 -start
       Map<Id,User> mapContactId2User = new Map<Id,User>();
        if(UserList!=null) {
            for(User objUser : UserList) {
                mapContactId2User.put(objUser.ContactId, objUser);
            }
        }
        //added by amritesh 11/12/2017 - US80097 - end
       for(Contact con: contList){
           IPSMemberWrapper wrapper = new IPSMemberWrapper();
           wrapper.selected=false;
           wrapper.con=con;
           //commented by amritesh 11/12/2017 - US80097
           //for(User u:UserList){
           //    if(U.contactid == con.id)
           //        wrapper.Usr=u;               
           //}
           
           //added by amritesh 11/12/2017 - US80097
           if(mapContactId2User.containsKey(con.Id)) {
                wrapper.Usr=mapContactId2User.get(con.Id);
           }
           wrapperInContext.add(wrapper);
       }
        
       if(wrapperInContext.size()>0){
            displayAddMemberSection = true;
        }else{
            displayAddMemberSection = false;
        }
       return wrapperInContext;
    }*/
    
    @RemoteAction
    global static List<IPSAccountWrapper> getAccountsWrapper(string projectId){
    
         acctWrapperList = new List<IPSAccountWrapper>();
         Set<Id> existingAccountIdSet = getExistingIPSAccountIds(ProjectId);
        List<Account> acctList = getAccounts(existingAccountIdSet);

        if(acctList!= null && acctList.size()>0){
            for(Account acc: acctList){
                IPSAccountWrapper wrapper = new IPSAccountWrapper();
                wrapper.acc = acc;
                //wrapper.participants = participantTypes; 
                wrapper.participantTypeSelected = '';
                wrapper.selected = false;
                //Added for US104027 by Aparna
                wrapper.ownrname= acc.owner.Name;
                /*--START--US964686-- 30/4/2024 -- Farooq -- Replaced CIM ID with Businesss_Party_Id--*/
                // start 10/7/2024 venkatesh added CIM ID and Businesss_Party_Id 
                if(label.Core_IPS_UCD_Toggle_Switch == '1'){
                    wrapper.unifiedID = acc.Core_Business_Party_Id__c;
                }else if(label.Core_IPS_UCD_Toggle_Switch == '0'){
                    wrapper.cimID = acc.Core_CIM_ID__c; 
                }   
                // stop 10/7/2024 venkatesh added CIM ID and Businesss_Party_Id          
                /*--Stop--US964686-- 30/4/2024 -- Farooq -- Replaced CIM ID with Businesss_Party_Id--*/
                wrapper.accntID = acc.Id; //Added by Aparna for US108704-PSG Independent Release
                //end by Aparna
                acctWrapperList.add(wrapper);
            }
        }
         if(acctWrapperList.size()>0){
            //displayAddSection = true;
        }else{
            //displayAddSection = false;
        }
        return acctWrapperList;

    }
    
    static Set<id> getExistingIPSAccountIds(string projectId){
         //existingAccounts = [select id, name,core_account__r.name, core_account__c, Core_Members__c from core_ips_account__c where core_ips_project__c= :projectId];
        // if(existingAccounts!=null && existingAccounts.size()>0){
            // //displayExistingAccounts=true;
        // }else{
            // //displayExistingAccounts =false;
        // }        
         Set<Id> existingAccountIdSet = new Set<id>();
        //Added Acc Owner Name and CIM Id for US104027 by Aparna
        //FLS Check Added - Yasasvi
        if(core_ips_account__c.SObjectType.getDescribe().isAccessible()){
            /*--START--US964686-- 30/4/2024 -- Farooq -- Replaced CIM ID with Businesss_Party_Id--*/
            //10/7/2024 venkatesh added CIM ID and Businesss_Party_Id
            for(core_ips_account__c ipsAcct:[select id, name,core_account__r.name,core_account__r.Core_Business_Party_Id__c,core_account__r.Core_CIM_ID__c,core_account__r.Owner.Name,core_account__c, Core_Members__c from core_ips_account__c where core_ips_project__c= :projectId]){
            /*--Stop--US964686-- 30/4/2024 -- Farooq -- Replaced CIM ID with Businesss_Party_Id--*/
                existingAccountIdSet.add(ipsAcct.core_account__c);
            }
        }
        if(existingAccountIdSet.size()>0){
            return existingAccountIdSet;
        } else{
            return null;
        }    
    }
    
    /* commented by amritesh 11/12/2017 - US80097
    @TestVisible private Set<id> getExistingIPSContIds(){
        existingMembers = [select id, name,Core_IPS_Contact__r.firstname,Core_IPS_Contact__r.lastname, core_ips_contact__c from Core_IPS_Project_Member__c where core_ips_project__c= :projectId and Core_Selective_Member__c = true];
        if(existingMembers!=null && existingMembers.size()>0){
            displayExistingMembers=true;
        }else{
            displayExistingMembers=false;
        }

        Set<Id> existingConIdSet = new Set<id>();
        for(Core_IPS_Project_Member__c ipsMem:existingMembers){
            existingConIdSet.add(ipsMem.core_ips_contact__c);
        }
        if(existingConIdSet.size()>0)
            return existingConIdSet;
        else
            return null;
    }
    */
    
    
    @TestVisible private List<SelectOption> getParticipantTypes(){
        List<SelectOption> participantTypes = new List<SelectOption>();
        participantTypes.add(new SelectOption('','Select One'));
        participantTypes.add(new SelectOption('All','All'));
        participantTypes.add(new SelectOption('Selective','Selective'));
        return participantTypes;
    }
    
    public PageReference addIPSAccounts(){
              /* start modified by Aayushi to display error message for invalid MPNDA field 11-03-17 US80374*/
        Integer checkVal;
        
        checkVal=addAccounts();
        
        if(checkVal==0){
        PageReference pg = new PageReference('/apex/Core_addProjectAccounts?projectId='+projectId);
        Pg.setRedirect(true);
        return Pg;
        }
        
        else if(checkVal==1){ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, nonNDAErrorMsg)); 
                             return null;
        }
        else if(checkVal==2){ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, mpndaErrorMsg)); 
                             return null;
             //end
        }
        else {return null;}             //modified my Aayushi 17/04/2018 DE37603
    }
    
    public PageReference addIPSAccountsAndDone(){
      /* start modified by Aayushi to display error message for invalid MPNDA field 11-03-17 US80374*/
       Integer checkVal;
        
        checkVal=addAccounts();
        
        if(checkVal==0){
        return new PageReference('/'+projectId); 
        }
        else if(checkVal==1){ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, nonNDAErrorMsg)); 
                             return null;}
        else if(checkVal==2){ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, mpndaErrorMsg)); 
                             return null;}
         //end
        else {return null;       }                  //modified my Aayushi 17/04/2018 DE37603
    }
    
    //return type modified by Aayushi US80368
    public Integer addAccounts(){
        /*--START--US964686-- 30/4/2021 -- Rekha -- get the members information and put it in map--*/
        List<string> participantsInfo;
        Map<String,String> participantsMap = new Map<String,String>();
        if (projectId != null && projectId != '' && Core_IPS_Project__c.SObjectType.getDescribe().isQueryable()) {
            Core_IPS_Project__c project = [Select Id, Core_IPS_Private__c from Core_IPS_Project__c where Id= :projectId];
            isPrivateProject = project?.Core_IPS_Private__c;
        }
        if (strAccountMembersInfo != null && strAccountMembersInfo != '') {
            List<string> lsttparticipantTypeSelected = strAccountMembersInfo.split(',');
            for (String participants: lsttparticipantTypeSelected) {
                if (participants != null && participants != '') {
                    participantsInfo = participants.split('=');
                    participantsMap.put(participantsInfo[0], participantsInfo[1]);
                }
            }
        }

        /*--End--US964686-- 30/4/2021 -- Rekha -- get the members information and put it in map--*/
        if(strAccountInfo !=null && strAccountInfo!='')
        {
            List<core_ips_account__c> ipsAcctList = new list<Core_ips_account__c>();
            List<string> lstAccountNeedToAdd = strAccountInfo.split(',');
            if(LstAccountNeedToAdd.size() > 0)
            {
                for(string strAccount : LstAccountNeedToAdd)
                {
                   if(strAccount!='')
                   {
                    List<string> lstAccountparticipantTypeSelected =  strAccount.split('=');
                    core_ips_account__c ipsAcct = new core_ips_account__c();
                   if (Schema.sObjectType.core_ips_account__c.fields.core_account__c.isCreateable()) { /**--US1038991--08/07/2021--HARITHA--FLS Check for security vulnerability--**/       
                        ipsAcct.core_account__c = ((id)LstAccountParticipantTypeSelected[0]);
                    }
                       /*--START--US964686-- 30/4/2021 -- Rekha -- assign member value core members field--*/
                       if (participantsMap.isEmpty() == false && participantsMap?.containsKey(LstAccountParticipantTypeSelected[0])) {
                           String mememberInfo = participantsMap.get(LstAccountParticipantTypeSelected[0]);
                           if (mememberInfo != null && mememberInfo != '' && isPrivateProject == false)
                           ipsAcct.core_members__c = mememberInfo;
                           else {
                               ipsAcct.core_members__c = 'Selective';
                                } 
                       } else {
                           //if (Schema.sObjectType.core_ips_account__c.fields.core_members__c.isCreateable()) { /**--US1038991--08/07/2021--HARITHA--FLS Check for security vulnerability--**/    
                               ipsAcct.core_members__c = 'Selective';
                           //}
                       } 
                       /*--End--US964686-- 30/4/2021 -- Rekha -- assign member value core members field--*/    
                       //}    
                    //modified by Aayushi US95034
                       /* if(LstAccountParticipantTypeSelected[1]=='None')
                            ipsAcct.core_members__c = 'Selective';
                        else
                            ipsAcct.core_members__c = LstAccountParticipantTypeSelected[1];*/
                     
                     if (Schema.sObjectType.core_ips_account__c.fields.core_ips_project__c.isCreateable()) { /**--US1038991--08/07/2021--HARITHA--FLS Check for security vulnerability--**/    
                         ipsAcct.core_ips_project__c = projectId;
                     }
                    // if (Schema.sObjectType.core_ips_account__c.fields.core_status__c.isCreateable()) { /**--US1038991--08/07/2021--HARITHA--FLS Check for security vulnerability--**/  
                         ipsAcct.core_status__c= 'Active';
                     //}
                     ipsAcctList.add(ipsAcct);
                    }
                   
                   
                }
            }
           // for(IPSAccountWrapper wrapper:acctWrapperList){
                // if(wrapper.selected){
                    // core_ips_account__c ipsAcct = new core_ips_account__c();
                    // ipsAcct.core_account__c = wrapper.acc.id;
                    // if(wrapper.participantTypeSelected==null || wrapper.participantTypeSelected.trim().length()==0)
                        // ipsAcct.core_members__c = 'Selective';
                    // else
                        // ipsAcct.core_members__c = wrapper.participantTypeSelected;
                    // ipsAcct.core_ips_project__c = projectId;
                    // ipsAcct.core_status__c= 'Active';
                    // ipsAcctList.add(ipsAcct);
                // }
            // }
            /*modified by Aayushi to check MPNDA field 11-03-17 US80374*/
            if(ipsAcctList.size()>0){
                Integer noOfAcct;
                Core_IPS_Project__c proj= new Core_IPS_Project__c();
               //added by Aayushi US80368 
                List<Id> ipsAcctId=new List<Id>();
                Set<Id> accId=new Set<Id>();
                List<Account> accountList=new List<Account>();
                for(core_ips_account__c ipsAcct:ipsAcctList){
                  ipsAcctId.add(ipsAcct.core_ips_project__c)  ;
                }
                if(ipsAcctId.size()>0){
                    //FLS Check Added - Yasasvi
                    if(Core_IPS_Project__c.SObjectType.getDescribe().isAccessible()){
                        proj=[Select Id,Core_Number_of_Accounts__c,Core_MPNDA__c from Core_IPS_Project__c where Id= :ipsAcctId.get(0) LIMIT 1];
                    }
                }
                    if(ipsAcctList.size()>1){
                        noOfAcct=Integer.valueOf(proj.Core_Number_of_Accounts__c)+2;
                        // start added by Aayushi US80368
                        for(core_ips_account__c projAcct: ipsAcctList){
                            accId.add(projAcct.core_account__c);
                        }
                            if(accId.size()>0){
                                //FLS Check Added - Gangadhar
                            if(Account.SObjectType.getDescribe().isAccessible()){
                                accountList=[Select Id,Core_CNDA_Number__c from Account where Id in :accId];
                                }
                            }        
                        if(accountList!=null){
                        for(Account acc: accountList){
                            if(String.isBlank(acc.Core_CNDA_Number__c)){
                                return 1; 
                            }
                        }
                        }
                       //end added by Aayushi US80368 
                    }
                    else{
                     noOfAcct=Integer.valueOf(proj.Core_Number_of_Accounts__c)+1;   
                    }
                    if(noOfAcct>1 && (proj.Core_MPNDA__c==null ||String.valueOf(proj.Core_MPNDA__c).trim()=='' )){
                        return 2;           //return type modified by Aayushi US80368
                    }
                
                
               //acctWrapperList = new List<IPSAccountWrapper>();
               //acctWrapperList = getAccountsWrapper(getExistingIPSAccountIds(),getParticipantTypes());
                //added try catch block Aayushi 17/04/2018 DE37603
                try{
                    insert ipsAcctList;}
                catch(Exception e){  
                    return 3;  }
   
            }
            
        }
        return 0;
    }
    
    public PageReference add(){
        addIPSProjectMembers();
        return null;
    }
    
    public PageReference addAndDone(){
        addIPSProjectMembers();
        return null;
    }
    
    public PageReference redirecttoparent(){
        return new PageReference('/'+projectId);
    }
    
    
    public PageReference actionMethod(){
    //Modified SOQL for US104027 by Aparna
    /*--START--US964686-- 30/4/2024 -- Farooq -- Replaced CIM ID with Businesss_Party_Id--*/
    //10/7/2024 venkatesh added CIM ID and Businesss_Party_Id
    existingAccounts = [select id, name,core_account__r.name,core_account__r.owner.Name,core_account__r.Core_Business_Party_Id__c,core_account__r.Core_CIM_ID__c,core_account__c, Core_Members__c from core_ips_account__c where core_ips_project__c= :projectId];
    /*--Stop--US964686-- 30/4/2024 -- Farooq -- Replaced CIM ID with Businesss_Party_Id--*/
    /*Set<Id> existingAccountIdSet = new Set<id>();
        for(core_ips_account__c ipsAcct:[select id, name,core_account__r.name, core_account__c, Core_Members__c from core_ips_account__c where core_ips_project__c =: projectId]){
            existingAccountIdSet.add(ipsAcct.core_account__c);
        }*/
    return null;
    }
    
    
    @TestVisible private void addIPSProjectMembers(){
        List<Core_IPS_Project_Member__c> ipsMemList = new list<Core_IPS_Project_Member__c>();
        for(IPSMemberWrapper wrapper:contWrapperList){
            if(wrapper.selected){
                Core_IPS_Project_Member__c ipsMem = new Core_IPS_Project_Member__c();
               // if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_IPS_Contact__c.isCreateable()) { /**--US1038991--08/07/2021--HARITHA--FLS Check for security vulnerability--**/
                    ipsMem.Core_IPS_Contact__c = wrapper.con.id;
                //}
               // if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_User__c.isCreateable()) { /**--US1038991--08/07/2021--HARITHA--FLS Check for security vulnerability--**/
                    ipsMem.Core_User__c = wrapper.Usr.id;
                //}
                if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.core_ips_project__c.isCreateable()) { /**--US1038991--08/07/2021--HARITHA--FLS Check for security vulnerability--**/
                    ipsMem.core_ips_project__c = projectId;
                }
                //if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_Selective_Member__c.isCreateable()) { /**--US1038991--08/07/2021--HARITHA--FLS Check for security vulnerability--**/
                    ipsMem.Core_Selective_Member__c = true;
                //}
                //if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.core_status__c.isCreateable()) { /**--US1038991--08/07/2021--HARITHA--FLS Check for security vulnerability--**/
                    ipsMem.core_status__c= 'Active';
                //}
                ipsMemList.add(ipsMem);
            }
        }
        if(ipsMemList.size()>0){
            insert ipsMemList;
            contWrapperList= new List<IPSMemberWrapper>();
            //contWrapperList= getContactsWrapper(getExistingIPSContIds()); //commented by amritesh 11/12/2017 - US80097
            
        }
      
    }
    
    public PageReference checkPageException(){
        if(throwPageException()){
            return null;
        }
        return null;
    }
    
    
    
    @TestVisible private boolean throwPageException(){
        if(String.isBlank(projectId)){
       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Invalid URL'));
       errorMessage=true;
            return true;
        }
        User u = [select profile.name from user where id=:userInfo.getUserId()];
        //FLS Check Added - Yasasvi
        if(core_ips_project__c.SObjectType.getDescribe().isAccessible()){
            project = [select id,Core_Number_of_Accounts__c from core_ips_project__c where id=:projectId limit 1];
        }
        List<Core_IPS_Account__c> projAccList=[Select Id,Core_Account__r.Core_CNDA_Number__c from Core_IPS_Account__c where Core_IPS_Project__c =:projectId];
        boolean profilefound = false;
        List<String> profileList = System.Label.Core_IPS_Profiles_AddAccountPrevention.split(';');
        for(String profile: ProfileList){
            if(Profile == u.profile.name){
                profilefound = true;    
            }   
        } 
        // start Modified by Aayushi for DE33732 13/12/2017 
      /*  if(project!=null && profilefound){
            //Modified by Aayushi 2-11-17 US79852
            if(project.core_status__c!=status){
                errorMsg='Accounts cannot be added if status is not Draft';
                displayErrorSection=true;
                return true;
                }
        }  */ //end of change for DE33732
        
        if(projAccList!=null && projAccList.size()>0){
        for(Core_IPS_Account__c projAcc: projAccList){
        If(String.isBlank(projAcc.Core_Account__r.Core_CNDA_Number__c)){
        errorMsg =String.isNotBlank(Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_cndaErrorMsg')) ? Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_cndaErrorMsg') : 'Any existing Account must have a CNDA prior to adding additional Accounts to a Premier Support Project';
         displayErrorSection = true; 
            return true;
         break; 
          }
         }
        }
       
        //check for edit access , Added by Amritesh 11/12/2017 - US80097-start
        Boolean hasEditAccess = hasProjectEditAccess(projectId, UserInfo.getUserId());
        if(!hasEditAccess) {
            errorMsg = String.isNotBlank(Core_IPS_Helper_Utility.getIPSLabel('noPermissiontoAddAccount')) ? Core_IPS_Helper_Utility.getIPSLabel('noPermissiontoAddAccount') : 'You do not have permission to Add Account';
            displayErrorSection = true; 
            return true;
        }
        //check for edit access , Added by Amritesh 11/12/2017 - US80097 -end
        if(displayErrorSection==null) {
            displayErrorSection=false;
        }
        return false;
    }
    
    public PageReference cancel(){
        return new PageReference('/'+projectId);
    }
    
    public static String getIPSUserType(){
        //ID profileId = userInfo.getProfileId();
        User u = [select id, profile.name from user where profileId=:userinfo.getProfileId() limit 1];
        Set<string> prflNameSet = new Set<string>();
        prflNameSet.addAll(Label.Core_IPS_ProjAccount_ProfileSet.split(';'));
        
        if(prflNameSet.contains(u.profile.name)){
            return System.Label.IPS_User_FAE;
        }else if(u.profile.name.contains('IPS Agent')){
            return System.Label.IPS_User_TME;
        }else if(u.profile.name.contains('IPS Support Org Admin')){
            return System.Label.IPS_User_Admin;
        }else if(u.profile.name.contains('IPS External Contact')){
            return System.Label.IPS_User_External;
        }
        return null;
    }
    
    public static List<Account> extAcctList;
    public static List<Account> getAccounts(Set<id> extAcctIdSet){
        //start added by Aayushi 02-23-2018 US80368
        List<Account> acctList=new List<Account>();
        Boolean checkNDAAccount=false;
        if(extAcctIdSet!=null && extAcctIdSet.size()>0){
        //Modified SOQL for US104027 by Aparna on 18/6/2018
        //FLS Check Added - Yasasvi
     if(Account.SObjectType.getDescribe().isAccessible()){
        /*--START--US964686-- 30/4/2024 -- Farooq -- Replaced CIM ID with Businesss_Party_Id--*/
        //10/7/2024 venkatesh added CIM ID along with Businesss_Party_Id
          extAcctList= [Select Id,name,Core_CNDA_Number__c,Owner.Name,Core_Business_Party_Id__c,Core_CIM_ID__c from Account where Id in :extAcctIdSet ];
        /*--Stop--US964686-- 30/4/2024 -- Farooq -- Replaced CIM ID with Businesss_Party_Id--*/
     }
            if(extAcctList.size()>0 && extAcctList!=null )
        {
            for(Account acct: extAcctList) {
                if(acct.Core_CNDA_Number__c !=null){
                  checkNDAAccount=true;
                    break;
                }
            } 
        }
        }
        //end US80368
        //Modified by Sugandha for US89550
        /*if(getIPSUserType()==System.Label.IPS_User_FAE){
            Set<Id> acctIdSet =  getFAEAccounts();
            if(extAcctIdSet!=null && extAcctIdSet.size()>0 && checkNDAAccount)      //if condition modified by Aayushi US80368
                acctList = [select id, name, Core_CNDA_Number__c from account where id in :acctIdSet and Core_IPS_Active__c=true and (Core_CNDA_Number__c!=null or Core_CNDA_Number__c!='') and id not in :extAcctIdSet ];
            else if(extAcctIdSet!=null && extAcctIdSet.size()>0 && !checkNDAAccount){
             acctList=null;   
            }
            else
                acctList = [select id, name, Core_CNDA_Number__c from account where id in :acctIdSet and Core_IPS_Active__c=true];
    }else{*/
            acctList = getAllIPSAccounts(extAcctIdSet,checkNDAAccount); //modified by Aayushi US80368
        //}
        if(acctList!=null && acctList.size()>0){
            return acctList;
        }else{
            return null;
        }    
    }
    
    public static Set<Id> getFAEAccounts(){
    //Logged In User Id
        set<Id> acctIdSet = new Set<Id>();
        Set<id> tempAcctIdSet = new Set<Id>();
    ////Get Accounts where the FAE is ISO
        /*tempAcctIdSet = getAccountsByISO();
    //Get Accounts Owned by the logged in FAE
        
    //Get Accounts that FAE is a team member of
        if(tempAcctIdSet!=null && tempAcctIdSet.size()>0){
            acctIdSet.addAll(tempAcctIdSet);
        }
        tempAcctIdSet.clear();*/
        tempAcctIdSet = getAccountsByTeam();
        if(tempAcctIdSet!=null && tempAcctIdSet.size()>0){
            acctIdSet.addAll(tempAcctIdSet);
        }
        tempAcctIdSet.clear();
        
        //Get All Accounts that are shared with FAE
        tempAcctIdSet = getManuallySharedAccounts();
        if(tempAcctIdSet!=null && tempAcctIdSet.size()>0){
            acctIdSet.addAll(tempAcctIdSet);
        }
        tempAcctIdSet.clear();
        //Set<id> accountsShared = getSharedAccounts();
        return acctIdSet;
    }
    
    @TestVisible private Static Set<id> getAccountsByISO(){
         List<Contact> contList;
        //FLS Check Added - Yasasvi
        if(Contact.SObjectType.getDescribe().isAccessible()){
            contList = [select id, name, accountid from Contact where Core_IPS_Intel_Support_Owner__c=:userInfo.getUserId()];
        }
        Set<Id> acctIdSet = new Set<Id>();
        for(Contact con:contList){
            acctIdSet.add(con.accountId);
        }
        return acctIdSet;
    }
    
    // private static Set<id> getAccountsByTeam(){
        // List<AccountTeamMember> acctTeamMemberList = [select accountId from AccountTeamMember where userid=:userInfo.getUserId()];
        // Set<id> acctIdSet = new Set<Id>();
        // for(AccountTeamMember member:acctTeamMemberList){
            // acctIdSet.add(member.accountId);
        // }
        // return acctIdSet;
    // }
    
    @TestVisible private static Set<id> getAccountsByTeam(){
        List<AccountShare> acctTeamMemberList;
        //FLS Check Added - Yasasvi
        if(accountshare.SObjectType.getDescribe().isAccessible()){
        acctTeamMemberList = [select accountid from accountshare where userorgroupid=:userInfo.getUserId() and rowcause in ('Team') and caseaccesslevel in ('Edit')];
        }
        Set<id> acctIdSet = new Set<Id>();
        for(AccountShare share:acctTeamMemberList){
            acctIdSet.add(share.accountId);
        }
        return acctIdSet;
    }
    
    public static Set<id> getManuallySharedAccounts(){
         List<AccountShare> manuallySharedAccountList;
        //FLS Check Added - Yasasvi
        if(AccountShare.SObjectType.getDescribe().isAccessible()){
            manuallySharedAccountList = [select accountid from accountshare where userorgroupid=:userInfo.getUserId() and rowcause in ('Owner')];
        }
        Set<id> acctIdSet = new Set<Id>();
        for(AccountShare share: manuallySharedAccountList){
            acctIdSet.add(share.accountId);
        }
        return acctIdSet;
    }
    
    //parameter added by Aayushi US80368
    @TestVisible private static List<Account> getAllIPSAccounts(Set<Id> acctIdSet,Boolean checkNDAAccount){
         //start modified by Aayushi 02-23-2018 US80368
        List<Account> acctList=new List<Account>();
        if(acctIdSet!=null && acctIdSet.size()>0 && checkNDAAccount){
            //Modified SOQL for US104027-PSG Independent Release by Aparna 
            //FLS Check Added - Yasasvi
            if(Account.SObjectType.getDescribe().isAccessible()){
                //US964686-- 30/4/2024 -- Farooq -- Replaced CIM ID with Businesss_Party_Id
                 //10/7/2024 venkatesh added CIM ID along with Businesss_Party_Id
                acctList = [select id,name,owner.Name,Core_Business_Party_Id__c,Core_CIM_ID__c from Account where Core_IPS_Active__c=true and (Core_CNDA_Number__c!=null or Core_CNDA_Number__c!='') and id not in :acctIdSet];
            }  
        }else if(acctIdSet!=null && acctIdSet.size()>0 && !checkNDAAccount)
        {
            acctList=null;
        }
        //end of modification aayushi
        else{
        //Added Owner name and CIM ID in SOQL for US104027 by Aparna
        //FLS Check Added - Yasasvi
            if(Account.SObjectType.getDescribe().isAccessible()){
                //START--US964686-- 30/4/2024 -- Farooq -- Replaced CIM ID with Businesss_Party_Id
                //10/7/2024 venkatesh added CIM ID along with Businesss_Party_Id
                acctList = [select id,name,owner.name,Core_Business_Party_Id__c,Core_CIM_ID__c from Account where Core_IPS_Active__c=true];
            }
        }
        return acctList;
 
    }
    
    public static List<Contact> getProjectMembers(Set<Id> acctIdSet){
        List<Contact> contList;
        if(acctIdSet!=null && acctIdSet.size()>0){
            //FLS Check Added - Yasasvi
            if(Contact.SObjectType.getDescribe().isAccessible()){
                contList = [select id, firstName, lastName, account.name from contact where accountId in :acctIdSet];
            }
        }
        return contList;
    }
    
    public static List<Core_ips_account__c> getSelectiveAccounts(String projectId){
    //Added owner name and cim id in SOQL for US104027 by Aparna
    //US964686-- 30/4/2024 -- Farooq -- Replaced CIM ID with Businesss_Party_Id
        List<Core_ips_account__c> ipsAcctList = [select id,Core_Account__r.Owner.name,Core_Account__r.Core_Business_Party_Id__c,core_account__r.Core_CIM_ID__c,core_account__c from core_ips_account__c where core_ips_project__c =:projectId and core_members__c='Selective'];  
        return ipsAcctList;
    }
        
    //method added Added by Amritesh 11/12/2017 - US80097
    public static Boolean hasProjectEditAccess(Id projectId, Id userId) {
        Boolean hasProjectEditAccess = false;
        UserRecordAccess objURA = [SELECT RecordId,HasEditAccess FROM UserRecordAccess WHERE UserId=:UserId AND RecordId=:ProjectId];
        if(objURA!=null) {
            hasProjectEditAccess = objURA.HasEditAccess;
        }
        return hasProjectEditAccess;
    }
    
}