public with sharing class Core_IPS_CaseCommentsController{
    
    public transient List<CaseCommentWrapper> CommentRecordsWrapper {get;set;}
    public transient List<Core_IPS_Case_Comments__c> cmmntList {get;set;}
    
    /**************** Loggedin User variables*************/
    public String ProfileName = System.Label.Core_IPS_Profile_Name;
    
    //***Following new variables added to incorporate Profile matching criteria - DE20841 ***
    public String profilenameDataMig =System.Label.Core_IPS_Data_Migration_Profile_Name;
    public string profilenameSalesRepBB =System.Label.Core_IPS_Sales_RepBB_Profile_Name;
    public string profilenameDataOps =System.label.Core_IPS_Data_Ops_Profile_Name;
    public string profilenameSalesManager =System.label.Core_IPS_Sales_Manager_Profile_Name;
    public string profilenameSalesOps =System.label.Core_IPS_Sales_Ops_Profile_Name;
    public string profilenameSalesRepCW =System.label.Core_IPS_Sales_RepCW_Profile_Name;
    public boolean isRendered_ExtIntNoteToCust{get;set;}
    public boolean isRendered_ExtIntsalesNoteToCust{get;set;}
    public boolean isRendered_ExtExtNoteFromCust{get;set;}
    public boolean isRendered_ExtDataCommLog{get;set;}
    public boolean isRendered_IntIntNotetoCust{get;set;}
    public boolean isRendered_IntIntNote{get;set;}    
    public boolean isRendered_IntExtNoteFromCust{get;set;}
    public boolean isRendered_IntIntsalesNoteToCust{get;set;}
    public boolean isRendered_IntIntdataopsNoteFromCust{get;set;}
    public boolean isRendered_IntIntsalesmanagerNoteFromCust{get;set;}
    public boolean isRendered_IntIntsalesopsNoteFromCust{get;set;}    
    public boolean isRendered_IntIntsalesrepcwNoteFromCust{get;set;}
    public boolean isRendered_IntDataMigCommLog{get;set;}
    public boolean isRendered_IntDataMigCommLogPublic{get;set;} 
    public boolean isRendered_ExtIntNoteToCust_FirstName{get;set;}
    public boolean isRendered_ExtIntsalesNoteToCust_FirstName{get;set;}
    public boolean isRendered_ExtExtNoteFromCust_Name{get;set;}
    public boolean isRendered_ExtDataCommLog_FirstName{get;set;}
    public boolean isRendered_IntIntNotetoCust_Name{get;set;}
    public boolean isRendered_IntIntNote_Name{get;set;}    
    public boolean isRendered_IntExtNoteFromCust_Name{get;set;}
    public boolean isRendered_IntIntsalesNoteToCust_Name{get;set;}
    public boolean isRendered_IntIntdataopsNoteFromCust_Name{get;set;}
    public boolean isRendered_IntIntsalesmanagerNoteFromCust_Name{get;set;}
    public boolean isRendered_IntIntsalesopsNoteFromCust_Name{get;set;}    
    public boolean isRendered_IntIntsalesrepcwNoteFromCust_Name{get;set;}
    public boolean isRendered_IntDataMigCommLog_Name{get;set;}
    public boolean isRendered_IntDataMigCommLogPublic_Name{get;set;}
    
    /*******************************************************************/    
    
    public Core_IPS_CaseCommentsController(ApexPages.StandardController controller){
        cmmntList = new List<Core_IPS_Case_Comments__c>();
        if(Core_IPS_Case_Comments__c.SObjectType.getDescribe().isAccessible()){
            cmmntList =[select id,name,Core_IPS_Comment__c,Core_IPS_Rich_Comment__c,CreatedBy.name,CreatedBy.Profile.Name,
                        CreatedBy.Firstname,CreatedBy_FirstName__c,CreatedBy_Name__c,CreatedDate,Core_IPS_BgColor__c,Core_IPS_NickName__c,Core_IPS_Case_Comment_Type__c 
                        from Core_IPS_Case_Comments__c  where Core_IPS_Case__c=:controller.getrecord().Id 
                        ORDER BY CreatedDate DESC NULLS LAST limit 1000
                       ]; 
            
        }
        if(!cmmntList.isEmpty())
            getStatus(cmmntList);
        
    }
    
    Profile loggedInUserProfile =[select id,name from Profile where Id=:userInfo.getProfileId()]; 
    
    /*****************/
    public void getStatus(List<Core_IPS_Case_Comments__c> csList) 
    {   
        CommentRecordsWrapper= new list<CaseCommentWrapper>();
        for(Core_IPS_Case_Comments__c cs:csList)
        {
            //****For External Logged In User and Case Comment created by Internal User and comment is Public[Note To Customer]****
            isRendered_ExtIntNoteToCust = (loggedInUserProfile.name==ProfileName && cs.createdBy.Profile.name!=ProfileName && 
                                           (Core_IPS_DataMigrationUser_Validation.isIPSDatamigrationUser(cs.CreatedById) == FALSE) && cs.createdBy.Profile.name != profilenameSalesRepBB  &&
                                           cs.createdBy.Profile.name != profilenameDataOps  && cs.createdBy.Profile.name != profilenameSalesManager  &&
                                           cs.createdBy.Profile.name != profilenameSalesOps && cs.createdBy.Profile.name != profilenameSalesRepCW);      //TWC745-6044 -Merging IPS Data Migration Profile to generic profile -CCP Core Access                          
            
            isRendered_ExtIntNoteToCust_Firstname = (loggedInUserProfile.Name==ProfileName && cs.createdBy.Profile.name!=ProfileName);                                 
            
            //****For External Logged In User and Case Comment created by Internal User(Sales) and comment is Public[Note To Customer]****
            isRendered_ExtIntsalesNoteToCust = (loggedInUserProfile.name==ProfileName && cs.createdBy.Profile.name==ProfileName && 
                                                (Core_IPS_DataMigrationUser_Validation.isIPSDatamigrationUser(cs.CreatedById) == FALSE) && cs.createdBy.Profile.name == profilenameSalesRepBB   &&
                                                cs.createdBy.Profile.name == profilenameDataOps  && cs.createdBy.Profile.name == profilenameSalesManager &&
                                                cs.createdBy.Profile.name == profilenameSalesOps && cs.createdBy.Profile.name == profilenameSalesRepCW);    //TWC745-6044 -Merging IPS Data Migration Profile to generic profile -CCP Core Access          
            
            isRendered_ExtIntsalesNoteToCust_FirstName = (loggedInUserProfile.Name== ProfileName && cs.createdBy.Profile.name!= ProfileName && 
                                                          (Core_IPS_DataMigrationUser_Validation.isIPSDatamigrationUser(cs.CreatedById) == FALSE) && cs.createdBy.Profile.name == profilenameSalesRepBB   &&
                                                          cs.createdBy.Profile.name == profilenameDataOps  && cs.createdBy.Profile.name == profilenameSalesManager &&
                                                          cs.createdBy.Profile.name == profilenameSalesOps && cs.createdBy.Profile.name == profilenameSalesRepCW);   //TWC745-6044 -Merging IPS Data Migration Profile to generic profile -CCP Core Access         
            
            //***For External Logged In User and Case Comment created by External user and comment is Public[Note from Customer]
            isRendered_ExtExtNoteFromCust_name = (loggedInUserProfile.name==ProfileName && cs.createdBy.Profile.name==ProfileName);
            isRendered_ExtExtNoteFromCust      = isRendered_ExtExtNoteFromCust_name;
            
            
            //***For External Logged In User and Case Comment created by Data Migration and Comment is Public [Communication Log]
            isRendered_ExtDataCommLog = (loggedInUserProfile.name==ProfileName && (Core_IPS_DataMigrationUser_Validation.isIPSDatamigrationUser(cs.CreatedById) == TRUE)); //TWC745-6044 -Merging IPS Data Migration Profile to generic profile -CCP Core Access
            
            isRendered_ExtDataCommLog_FirstName = (loggedInUserProfile.Name==ProfileName && cs.createdBy.Profile.name!=ProfileName);                                
            
            
            //***For Internal Logged In User and Case Comment created by Internal User and comment is Public[Note To Customer]  
            isRendered_IntIntNotetoCust_name = (loggedInUserProfile.Name!=ProfileName && cs.createdBy.Profile.name!= ProfileName && 
                                                cs.createdBy.Profile.name != profilenameSalesRepBB   && cs.createdBy.Profile.name != profilenameDataOps && 
                                                cs.createdBy.Profile.name != profilenameSalesManager && cs.createdBy.Profile.name != profilenameSalesOps && 
                                                cs.createdBy.Profile.name != profilenameSalesRepCW   && cs.createdBy.Profile.name != profilenameDataMig);                                                
            
            isRendered_IntIntNotetoCust = (isRendered_IntIntNotetoCust_name && cs.Core_IPS_Case_Comment_Type__c == Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c);                                                  
            
            
            
            //For Internal Logged In User and Case Comment created by Internal User and comment is NOT Public[InternalNote]
            isRendered_IntIntNote_name = (loggedInUserProfile.Name!=ProfileName && cs.createdBy.Profile.name!=ProfileName && cs.createdBy.Profile.name!= profilenameDataMig);                                  
            isRendered_IntIntNote      = (isRendered_IntIntNote_name && cs.Core_IPS_Case_Comment_Type__c != Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c);                                                          
            
            
            //For Internal Logged In User and Case Comment created by External User and comment is Public[Note From Customer]           
            isRendered_IntExtNoteFromCust_name = (loggedInUserProfile.Name!=ProfileName && cs.createdBy.Profile.name==ProfileName);                 
            isRendered_IntExtNoteFromCust      = isRendered_IntExtNoteFromCust_name;                                        
            
            
            //For Internal Logged In User and Case Comment created by Internal(Sales Rep BB)and comment is Public[Note From Customer] 
            isRendered_IntIntsalesNoteToCust_name = (loggedInUserProfile.Name!=ProfileName && cs.createdBy.Profile.name == profilenameSalesRepBB);                   
            isRendered_IntIntsalesNoteToCust      = (isRendered_IntIntsalesNoteToCust_name && cs.Core_IPS_Case_Comment_Type__c == Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c);                                        
            
            
            //For Internal Logged In User and Case Comment created by Internal(Data Ops)and comment is Public[Note From Customer]
            isRendered_IntIntdataopsNoteFromCust_name = (loggedInUserProfile.Name!=ProfileName && cs.createdBy.Profile.name == profilenameDataOps);               
            isRendered_IntIntdataopsNoteFromCust      = (isRendered_IntIntdataopsNoteFromCust_name && cs.Core_IPS_Case_Comment_Type__c == Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c);                                 
            
            
            //For Internal Logged In User and Case Comment created by Internal(Sales Manager)and comment is Public[Note From Customer]  
            isRendered_IntIntsalesmanagerNoteFromCust_name = (loggedInUserProfile.Name!=ProfileName && cs.createdBy.Profile.name == profilenameSalesManager);
            isRendered_IntIntsalesmanagerNoteFromCust      = (isRendered_IntIntsalesmanagerNoteFromCust_name && cs.Core_IPS_Case_Comment_Type__c == Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c);                  
            
            
            //***For Internal Logged In User and Case Comment created by Internal(Sales Ops)and comment is Public[Note From Customer] 
            isRendered_IntIntsalesopsNoteFromCust_name = (loggedInUserProfile.Name!=ProfileName && cs.createdBy.Profile.name == profilenameSalesOps);              
            isRendered_IntIntsalesopsNoteFromCust      = (isRendered_IntIntsalesopsNoteFromCust_name && cs.Core_IPS_Case_Comment_Type__c == Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c);                
            
            
            //***For Internal Logged In User and Case Comment created by Internal(Sales Rep CW)and comment is Public[Note From Customer]
            isRendered_IntIntsalesrepcwNoteFromCust_name = (loggedInUserProfile.Name!=ProfileName && cs.createdBy.Profile.name == profilenameSalesRepCW);                  
            isRendered_IntIntsalesrepcwNoteFromCust      = (isRendered_IntIntsalesrepcwNoteFromCust_name && cs.Core_IPS_Case_Comment_Type__c == Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c);                
            
            
            //***For Internal Logged In User and Case Comment created by Data migration and comment is NOT Public[Communication Log]
            isRendered_IntDataMigCommLog_name = (loggedInUserProfile.Name != ProfileName && (Core_IPS_DataMigrationUser_Validation.isIPSDatamigrationUser(cs.CreatedById) == TRUE)); //TWC745-6044 -Merging IPS Data Migration Profile to generic profile -CCP Core Access
            isRendered_IntDataMigCommLog      = (isRendered_IntDataMigCommLog_name && cs.Core_IPS_Case_Comment_Type__c != Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c);            
            
            
            //***For Internal Logged In User and Case Comment created by Data migration and comment is Public[Communication Log]  
            isRendered_IntDataMigCommLogPublic_name = (loggedInUserProfile.Name!=ProfileName && (Core_IPS_DataMigrationUser_Validation.isIPSDatamigrationUser(cs.CreatedById) == TRUE)); //TWC745-6044 -Merging IPS Data Migration Profile to generic profile -CCP Core Access                                
            isRendered_IntDataMigCommLogPublic      = (isRendered_IntDataMigCommLogPublic_name && cs.Core_IPS_Case_Comment_Type__c == Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c);                                   
            
            
            CommentRecordsWrapper.add(new CaseCommentWrapper(cs,isRendered_ExtIntNoteToCust,
                                                             isRendered_ExtIntsalesNoteToCust,
                                                             isRendered_ExtExtNoteFromCust,
                                                             isRendered_ExtDataCommLog,
                                                             isRendered_IntIntNotetoCust,
                                                             isRendered_IntIntNote,
                                                             isRendered_IntExtNoteFromCust,
                                                             isRendered_IntIntsalesNoteToCust,
                                                             isRendered_IntIntdataopsNoteFromCust,
                                                             isRendered_IntIntsalesmanagerNoteFromCust,
                                                             isRendered_IntIntsalesopsNoteFromCust,
                                                             isRendered_IntIntsalesrepcwNoteFromCust,
                                                             isRendered_IntDataMigCommLog,
                                                             isRendered_IntDataMigCommLogPublic,
                                                             isRendered_ExtIntNoteToCust_FirstName,
                                                             isRendered_ExtIntsalesNoteToCust_FirstName,
                                                             isRendered_ExtExtNoteFromCust_Name,
                                                             isRendered_ExtDataCommLog_FirstName,
                                                             isRendered_IntIntNotetoCust_Name,
                                                             isRendered_IntIntNote_Name,
                                                             isRendered_IntExtNoteFromCust_Name,
                                                             isRendered_IntIntsalesNoteToCust_Name,
                                                             isRendered_IntIntdataopsNoteFromCust_Name,
                                                             isRendered_IntIntsalesmanagerNoteFromCust_Name,
                                                             isRendered_IntIntsalesopsNoteFromCust_Name,  
                                                             isRendered_IntIntsalesrepcwNoteFromCust_Name,
                                                             isRendered_IntDataMigCommLog_Name,
                                                             isRendered_IntDataMigCommLogPublic_Name
                                                            )
                                     );  
            //casecommentsString = JSON.serialize(CommentRecordsWrapper);                                                           
        }    
    }
    
    /**********/
    
    // Wrapper Class added to incorporate profile matching criteria - DE20841 ***
    /***/
    public  class CaseCommentWrapper{
        public Core_IPS_Case_Comments__c cs {get;set;}
        public boolean isRendered_ExtIntNoteToCust{get;set;}
        public boolean isRendered_ExtIntsalesNoteToCust{get;set;}
        public boolean isRendered_ExtExtNoteFromCust{get;set;}
        public boolean isRendered_ExtDataCommLog{get;set;}
        public boolean isRendered_IntIntNotetoCust{get;set;}
        public boolean isRendered_IntIntNote{get;set;}    
        public boolean isRendered_IntExtNoteFromCust{get;set;}
        public boolean isRendered_IntIntsalesNoteToCust{get;set;}
        public boolean isRendered_IntIntdataopsNoteFromCust{get;set;}
        public boolean isRendered_IntIntsalesmanagerNoteFromCust{get;set;}
        public boolean isRendered_IntIntsalesopsNoteFromCust{get;set;}    
        public boolean isRendered_IntIntsalesrepcwNoteFromCust{get;set;}
        public boolean isRendered_IntDataMigCommLog{get;set;}
        public boolean isRendered_IntDataMigCommLogPublic{get;set;} 
        public boolean isRendered_ExtIntNoteToCust_FirstName{get;set;}
        public boolean isRendered_ExtIntsalesNoteToCust_FirstName{get;set;}
        public boolean isRendered_ExtExtNoteFromCust_Name{get;set;}
        public boolean isRendered_ExtDataCommLog_FirstName{get;set;}
        public boolean isRendered_IntIntNotetoCust_Name{get;set;}
        public boolean isRendered_IntIntNote_Name{get;set;}
        public boolean isRendered_IntExtNoteFromCust_Name{get;set;}
        public boolean isRendered_IntIntsalesNoteToCust_Name{get;set;}
        public boolean isRendered_IntIntdataopsNoteFromCust_Name{get;set;}
        public boolean isRendered_IntIntsalesmanagerNoteFromCust_Name{get;set;}
        public boolean isRendered_IntIntsalesopsNoteFromCust_Name{get;set;}    
        public boolean isRendered_IntIntsalesrepcwNoteFromCust_Name{get;set;}
        public boolean isRendered_IntDataMigCommLog_Name{get;set;}
        public boolean isRendered_IntDataMigCommLogPublic_Name{get;set;}
        
        public CaseCommentWrapper(Core_IPS_Case_Comments__c cs, Boolean ExtIntNoteToCust,
                                  Boolean ExtIntsalesNoteToCust,Boolean ExtExtNoteFromCust,
                                  Boolean ExtDataCommLog,Boolean IntIntNotetoCust,Boolean IntIntNote,
                                  Boolean IntExtNoteFromCust,Boolean IntIntsalesNoteToCust,
                                  Boolean IntIntdataopsNoteFromCust,
                                  Boolean IntIntsalesmanagerNoteFromCust,Boolean IntIntsalesopsNoteFromCust,
                                  Boolean IntIntsalesrepcwNoteFromCust,Boolean IntDataMigCommLog,
                                  Boolean IntDataMigCommLogPublic, Boolean ExtIntNoteToCust_FirstName,
                                  Boolean ExtIntsalesNoteToCust_FirstName, Boolean ExtExtNoteFromCust_Name,
                                  Boolean ExtDataCommLog_FirstName, Boolean IntIntNotetoCust_Name,
                                  Boolean IntIntNote_Name, Boolean IntExtNoteFromCust_Name,
                                  Boolean IntIntsalesNoteToCust_Name, Boolean IntIntdataopsNoteFromCust_Name,
                                  Boolean IntIntsalesmanagerNoteFromCust_Name, Boolean IntIntsalesopsNoteFromCust_Name,  
                                  Boolean IntIntsalesrepcwNoteFromCust_Name, Boolean IntDataMigCommLog_Name,
                                  Boolean IntDataMigCommLogPublic_Name ){
                                      this.cs=cs;
                                      isRendered_ExtIntNoteToCust=ExtIntNoteToCust;
                                      isRendered_ExtIntsalesNoteToCust = ExtIntsalesNoteToCust;
                                      isRendered_ExtExtNoteFromCust = ExtExtNoteFromCust;
                                      isRendered_ExtDataCommLog = ExtDataCommLog;
                                      isRendered_IntIntNotetoCust = IntIntNotetoCust;
                                      isRendered_IntIntNote = IntIntNote;    
                                      isRendered_IntExtNoteFromCust =IntExtNoteFromCust;
                                      isRendered_IntIntsalesNoteToCust = IntIntsalesNoteToCust;
                                      isRendered_IntIntdataopsNoteFromCust = IntIntdataopsNoteFromCust;
                                      isRendered_IntIntsalesmanagerNoteFromCust = IntIntsalesmanagerNoteFromCust;
                                      isRendered_IntIntsalesopsNoteFromCust = IntIntsalesopsNoteFromCust;    
                                      isRendered_IntIntsalesrepcwNoteFromCust = IntIntsalesrepcwNoteFromCust;
                                      isRendered_IntDataMigCommLog = IntDataMigCommLog;
                                      isRendered_IntDataMigCommLogPublic = IntDataMigCommLogPublic;           
                                      isRendered_ExtIntNoteToCust_FirstName = ExtIntNoteToCust_FirstName;
                                      isRendered_ExtIntsalesNoteToCust_FirstName = ExtIntsalesNoteToCust_FirstName;
                                      isRendered_ExtExtNoteFromCust_Name = ExtExtNoteFromCust_Name;
                                      isRendered_ExtDataCommLog_FirstName = ExtDataCommLog_FirstName;
                                      isRendered_IntIntNotetoCust_Name = IntIntNotetoCust_Name;
                                      isRendered_IntIntNote_Name = IntIntNote_Name; 
                                      isRendered_IntExtNoteFromCust_Name = IntExtNoteFromCust_Name;
                                      isRendered_IntIntsalesNoteToCust_Name = IntIntsalesNoteToCust_Name;
                                      isRendered_IntIntdataopsNoteFromCust_Name = IntIntdataopsNoteFromCust_Name;
                                      isRendered_IntIntsalesmanagerNoteFromCust_Name = IntIntsalesmanagerNoteFromCust_Name;
                                      isRendered_IntIntsalesopsNoteFromCust_Name = IntIntsalesopsNoteFromCust_Name;   
                                      isRendered_IntIntsalesrepcwNoteFromCust_Name = IntIntsalesrepcwNoteFromCust_Name;
                                      isRendered_IntDataMigCommLog_Name = IntDataMigCommLog_Name;
                                      isRendered_IntDataMigCommLogPublic_Name = IntDataMigCommLogPublic_Name;       
                                  }
    }
    /*****/
    
}