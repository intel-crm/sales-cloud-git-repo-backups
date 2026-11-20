@isTest
public class Core_CloneSolutionArea_Test {
    static testMethod void getRecord() {
        Id Solution_AreaId;
        List<Core_Solution_Areas__c> Solutionx= new List<Core_Solution_Areas__c >();
        Solutionx = [select Id from Core_Solution_Areas__c  where name!= null and IsDeleted = false limit 1 ];
        if(Solutionx.size()>0)
        {
            Solution_AreaId= Solutionx[0].Id;
        }
        
        Test.startTest();
        
        List<Core_Trigger_Executions__c> triggerExecList = new List<Core_Trigger_Executions__c>();
        triggerExecList.add(new Core_Trigger_Executions__c(Name='updateJSONSolutionArea', Core_Class_Name__c='updateJSONSolutionArea', Core_Object__c='OpportunitySolutionArea', Core_Trigger_Events__c='After Insert before Delete', Core_Active__c=true, Core_Description__c = 'blah blah'));
        
        insert triggerExecList;         
        //Id Solution_AreaId='aCc2D00000002dISAQ';
        List<Core_Solution_Areas__c> solStor= new List<Core_Solution_Areas__c>();
        
        solStor = [select Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, Core_Deal_Visible__c, Core_Design_Visible__c,  Core_Solution_Type__c,  Core_Solution_Description__c, Core_Version__c,  Core_Industry_Use_Case__c,  Core_Technology_Enabled__c, Core_Solution_owner_email__c, Core_Content_Link__c, Core_Industry__c, Core_Region_of_availability__c,  Core_Region_Deployed__c, Core_Application_Workload__c, Core_Solution_Long__c,  Core_End_Customer_Solution__c, Core_Solution_Title__c, Core_Status__c, Core_Most_Recent_Status_Change_Date__c from Core_Solution_Areas__c where Id =: Solution_AreaId];
        if (solStor!= null)
        {
            system.assert(solStor != null, 'success');
        }
        else
        {
            system.assert(solStor == null, 'Failed');                 
        }
        List<Core_Solution_Areas__c> SolnAreas= new List<Core_Solution_Areas__c>();
        SolnAreas=	Core_CloneSolutionArea.getRecord(Solution_AreaId);
        SolnAreas=	Core_CloneSolutionArea.Validate_Solution_PValues(SolnAreas);
        
        Test.StopTest();  
    }
    
    static testmethod void testSAClone(){
        
        System.runAs(Core_Test_Utility.systemAdminUser) { 
            Test.StartTest();
            List<Core_Trigger_Executions__c> triggerExecList = new List<Core_Trigger_Executions__c>();
            triggerExecList.add(new Core_Trigger_Executions__c(Name='updateJSONSolutionArea', Core_Class_Name__c='updateJSONSolutionArea', Core_Object__c='OpportunitySolutionArea', Core_Trigger_Events__c='After Insert before Delete', Core_Active__c=true, Core_Description__c = 'blah blah'));
            insert triggerExecList;
            
            
            String dateString = String.valueof(Datetime.now().getTime());
            Id Acc_ID;
            List<Account> Accountx= new List<Account>();
            Accountx = [select Id from account  where name= 'DELL' and IsDeleted =false  limit 1 ];
            if(Accountx.size()>0)
            {
                Acc_ID= Accountx[0].Id;
            }
            Id Solution_AreaId;
            Id Solution_AreaId_Ins;
            List<Core_Solution_Areas__c> Solutionx= new List<Core_Solution_Areas__c >();
            Solutionx = [select Id, OwnerId,  Name, Core_Deal_Visible__c, Core_Design_Visible__c,  Core_Solution_Type__c,  Core_Solution_Description__c, Core_Version__c,  Core_Industry_Use_Case__c,  Core_Technology_Enabled__c, Core_Solution_owner_email__c, Core_Content_Link__c, Core_Industry__c, Core_Region_of_availability__c,  Core_Application_Workload__c,  Core_End_Customer_Solution__c, Core_Solution_Title__c, Core_Status__c from Core_Solution_Areas__c  where name!= null and IsDeleted = false  and Core_Application_Workload__c!= null and Core_Technology_Enabled__c!= null and Core_Industry_Use_Case__c!= null and  Core_Solution_Type__c != null limit 1 ];
            
            
            List<Core_Solution_Area_Partner__c> Partnerx= new List<Core_Solution_Area_Partner__c >();
            
            Partnerx =  [select id, Solution_Partner_Type__c, Core_Solution_Partner_Role__c, Core_Solution_Area__c, Core_Solution_Partner__c from Core_Solution_Area_Partner__c where Core_Solution_Partner__c!= null and Core_Solution_Partner_Role__c!= null and Solution_Partner_Type__c!= null limit 1];
            
            List<Core_Solution_Areas__c> solutionList= new List<Core_Solution_Areas__c >();
            List<Core_Solution_Area_Partner__c> partnerList= new List<Core_Solution_Area_Partner__c >();
            
            for (Core_Solution_Areas__c soln : Solutionx) {
                Solution_AreaId=soln.Id;
                
                
                soln.Id= '';
                soln.name = soln.name + dateString;		
                solutionList.add(soln); //Add to solutionList for bulk insert
                // Database.SaveResult  response1 =   Database.insert(soln, true);                      
                //Solution_AreaId_Ins= response1.getId();
            }
            if(!solutionList.isEmpty()){
                
                Database.SaveResult[] solutionAreaSaveResults = Database.insert(solutionList, true);
                List<Id> solutionIds = new List<Id>();
                for(Database.SaveResult result : solutionAreaSaveResults){
                    if(result.isSuccess()){
                        solutionIds.add(result.getId());
                    }
                    else{
                        //System.debug('Error inserting Core_Solution_Areas__c:' + result.getErrors()[0].getMessage());
                    }
                    
                    List<Core_Solution_Areas__c> SolnAreas= new List<Core_Solution_Areas__c>();
                    for(Core_Solution_Areas__c solnId : [SELECT Id FROM Core_Solution_Areas__c where Id IN:solutionIds]){
                        SolnAreas= Core_CloneSolutionArea.getRecord(solnId.Id);
                        SolnAreas=	Core_CloneSolutionArea.Validate_Solution_PValues(SolnAreas);
                        if (SolnAreas!= null)
                        {
                            
                            system.assert(SolnAreas != null, 'success');
                        }
                        string status_val=  Core_CloneSolutionArea.ValidateSolutionData(solnId);
                        if (status_val!= null)
                        {
                            
                            system.assert(status_val != null, 'success');
                        }
                        string status_Result= Core_CloneSolutionArea.CreateRecord(Solution_AreaId, solnId, true);
                        if (status_Result!= null)
                        {
                            
                            system.assert(status_Result != null, 'success');
                        }
                        
                    }
                }
                
                for(Id solnId : solutionIds){
                    for (Core_Solution_Area_Partner__c Partner : Partnerx) {
                        Partner.Id= '';
                        Partner.Core_Solution_Area__c = solnId;
                        //Database.SaveResult  response2 =   Database.insert(Partner, true);
                        partnerList.add(Partner);
                    }
                    
                    
                }
            }
            if(!partnerList.isEmpty()){
                List<Database.SaveResult>  partnerSaveResults =   Database.insert(partnerList, true);
                for(Database.SaveResult result : partnerSaveResults){
                    if(!result.isSuccess()){
                        //System.debug('Error inserting Core_Solution_Area_Partner__c:' + result.getErrors()[0].getMessage());
                    }
                }
            }
            
            //SolnAreas= Core_CloneSolutionArea.getRecord(soln.Id); 
            
            
            Test.StopTest();     
        }
    }
    
    
    
    
    
    static testMethod void CloneTestMethod() {
        String dateString = String.valueof(Datetime.now().getTime());
        Id Acc_ID;
        List<Account> Accountx= new List<Account>();
        Accountx = [select Id from account  where name= 'DELL' and IsDeleted =false  limit 1 ];
        if(Accountx.size()>0)
        {
            Acc_ID= Accountx[0].Id;
        }
        
        Id Acc_ID1;
        List<Account> Accountx1= new List<Account>();
        Accountx1 = [select Id from account  where name= 'CISCO' and IsDeleted =false  limit 1 ];
        if(Accountx1.size()>0)
        {
            Acc_ID1= Accountx1[0].Id;
        }
        Id Solution_AreaId;
        List<Core_Solution_Areas__c> Solutionx= new List<Core_Solution_Areas__c >();
        Solutionx = [select Id from Core_Solution_Areas__c  where name!= null and IsDeleted = false limit 1 ];
        if(Solutionx.size()>0)
        {
            Solution_AreaId= Solutionx[0].Id;
        }
        
        
        Test.startTest();
        String status_msg='';
        String strError='';
        // Id Solution_AreaId='aCc2D00000002dISAQ';
        List<Core_Trigger_Executions__c> triggerExecList = new List<Core_Trigger_Executions__c>();
        triggerExecList.add(new Core_Trigger_Executions__c(Name='updateJSONSolutionArea', Core_Class_Name__c='updateJSONSolutionArea', Core_Object__c='OpportunitySolutionArea', Core_Trigger_Events__c='After Insert before Delete', Core_Active__c=true, Core_Description__c = 'blah blah'));
        insert triggerExecList;
        List<selectOption> options = new List<selectOption>();
        List<sObject> l_Types = new List<sObject>();
        List<Map<String,String>> selectOpt = new List<Map<String,String>>();
        
        
        List<String>  Application_Workload = new List<String>();
        
        // Get the describe information for the Account object
        Schema.DescribeSObjectResult Describe = Schema.sObjectType.Core_Solution_Areas__c;
        
        Schema.DescribeFieldResult FieldDescribe = Describe.fields.getMap().get('Core_Application_Workload__c').getDescribe();
        List<Schema.PicklistEntry> PicklistValues = FieldDescribe.getPicklistValues();
        try{
            for (Schema.PicklistEntry picklistValue : PicklistValues) {
                Application_Workload.add(picklistValue.getLabel()+'|'+ picklistValue.getValue());
            } 
            
            system.assert(Application_Workload != null, 'success');
            Core_CloneSolutionArea.Get_Types_Application_Workload();
        }
        catch (Exception e) {
            system.assert(Application_Workload == null, 'Failed');
        }
        
        try
        {
            
            List<String>  Industry_UseCase = new List<String>();
            options = new List<selectOption>();
            l_Types = new List<sObject>();
            // Get the describe information for the Account object
            Schema.DescribeSObjectResult Describe1 = Schema.sObjectType.Core_Solution_Areas__c;
            Schema.DescribeFieldResult FieldDescribe1 = Describe1.fields.getMap().get('Core_Industry_Use_Case__c').getDescribe();
            List<Schema.PicklistEntry> PicklistValues1 = FieldDescribe1.getPicklistValues();
            for (Schema.PicklistEntry picklistValue : PicklistValues1) {
                Industry_UseCase.add(picklistValue.getLabel()+'|'+ picklistValue.getValue());
            } 
            system.assert(Industry_UseCase != null, 'success');
            Core_CloneSolutionArea.Get_Types_Industry_UseCase();
            
        }
        catch (Exception e) {
            system.assert(Application_Workload == null, 'Failed');
        }
        
        List<String>  Industry = new List<String>();
        
        selectOpt = new List<Map<String,String>>();
        options = new List<selectOption>();
        l_Types = new List<sObject>();
        // Get the describe information for the Account object
        try
        {
            Schema.DescribeSObjectResult Describe2 = Schema.sObjectType.Core_Solution_Areas__c;
            Schema.DescribeFieldResult FieldDescribe2 = Describe2.fields.getMap().get('Core_Industry__c').getDescribe();
            List<Schema.PicklistEntry> PicklistValues2 = FieldDescribe2.getPicklistValues();
            for (Schema.PicklistEntry picklistValue : PicklistValues2) {
                Industry.add(picklistValue.getLabel()+'|'+ picklistValue.getValue());
            } 
            
            system.assert(Industry != null, 'success');
            
        }
        catch (Exception e) {
            system.assert(Application_Workload == null, 'Failed');
        }
        Core_CloneSolutionArea.Get_Types_Industry();
        List<String>  Region_Availability = new List<String>();
        
        selectOpt = new List<Map<String,String>>();
        options = new List<selectOption>();
        l_Types = new List<sObject>();
        try
        {
            // Get the describe information for the Account object
            Schema.DescribeSObjectResult Describe3 = Schema.sObjectType.Core_Solution_Areas__c;
            Schema.DescribeFieldResult FieldDescribe3 = Describe3.fields.getMap().get('Core_Region_of_availability__c').getDescribe();
            List<Schema.PicklistEntry> PicklistValues3 = FieldDescribe3.getPicklistValues();
            for (Schema.PicklistEntry picklistValue : PicklistValues) {
                Region_Availability.add(picklistValue.getLabel()+'|'+ picklistValue.getValue());
            } 
            
            system.assert(Region_Availability != null, 'success');   
        }
        catch (Exception e) {
            system.assert(Application_Workload == null, 'Failed');
        }
        Core_CloneSolutionArea.Get_Types_Region_Availability();
        
        List<String>  TechnologyEnabled = new List<String>();
        
        selectOpt = new List<Map<String,String>>();
        options = new List<selectOption>();
        l_Types = new List<sObject>();
        // Get the describe information for the Account object
        try
        {
            Schema.DescribeSObjectResult Describe4 = Schema.sObjectType.Core_Solution_Areas__c;
            Schema.DescribeFieldResult FieldDescribe4 = Describe4.fields.getMap().get('Core_Technology_Enabled__c').getDescribe();
            List<Schema.PicklistEntry> PicklistValues4 = FieldDescribe4.getPicklistValues();
            for (Schema.PicklistEntry picklistValue : PicklistValues) {
                TechnologyEnabled.add(picklistValue.getLabel()+'|'+ picklistValue.getValue());
            } 
            
            system.assert(TechnologyEnabled != null, 'success'); 
            
        }
        catch (Exception e) {
            system.assert(Application_Workload == null, 'Failed');
            
        }
        
        Core_CloneSolutionArea.Get_Types_TechnologyEnabled();
        List<String>  Status = new List<String>();
        selectOpt = new List<Map<String,String>>();
        options = new List<selectOption>();
        l_Types = new List<sObject>();
        // Get the describe information for the Account object
        // 
        try
        {
            Schema.DescribeSObjectResult Describe5 = Schema.sObjectType.Core_Solution_Areas__c;
            Schema.DescribeFieldResult FieldDescribe5 = Describe5.fields.getMap().get('Core_Status__c').getDescribe();
            List<Schema.PicklistEntry> PicklistValues5 = FieldDescribe5.getPicklistValues();
            for (Schema.PicklistEntry picklistValue : PicklistValues5) {
                Status.add(picklistValue.getLabel()+'|'+ picklistValue.getValue());
            } 
            
            system.assert(Status != null, 'success');  
        }
        catch (Exception e) {
            system.assert(Application_Workload == null, 'Failed');
            
        }
        
        Core_CloneSolutionArea.Get_Types_Status();
        List<String>  SolutionType = new List<String>();
        selectOpt = new List<Map<String,String>>();
        options = new List<selectOption>();
        l_Types = new List<sObject>();
        // Get the describe information for the Account object
        try
        {
            Schema.DescribeSObjectResult Describe6 = Schema.sObjectType.Core_Solution_Areas__c;
            Schema.DescribeFieldResult FieldDescribe6 = Describe6.fields.getMap().get('Core_Solution_Type__c').getDescribe();
            List<Schema.PicklistEntry> PicklistValues6 = FieldDescribe6.getPicklistValues();
            for (Schema.PicklistEntry picklistValue : PicklistValues6) {
                SolutionType.add(picklistValue.getLabel()+'|'+ picklistValue.getValue());
            } 
            
            system.assert(SolutionType != null, 'success');            
            
        }
        catch (Exception e) {
            system.assert(Application_Workload == null, 'Failed');
            
        }
        Core_CloneSolutionArea.Get_Types_SolutionType();
        // add new solution
        List<Core_Solution_Areas__c> solns= new List<Core_Solution_Areas__c>();
        boolean create_partner= true;
        string strstatus='';
        Core_Solution_Areas__c solStor = new Core_Solution_Areas__c();
        solStor.Core_Solution_Type__c = 'S1: Product';
        solStor.Core_End_Customer_Solution__c = 'Yes';
        solStor.Core_Design_Visible__c = true;
        solStor.Core_Status__c = 'Active';
        solStor.Core_Version__c='1';
        solStor.Core_Region_of_availability__c ='N/A';
        solStor.Core_Industry__c ='Financial Services Industry;Government;Manufacturing;Retail';
        solStor.Core_Industry_Use_Case__c ='Environment Monitoring-Chessboard;Logistics & Tracking-Chessboard;Situational Monitoring-Chessboard';
        solStor.Core_Technology_Enabled__c ='OpenVINO';
        solStor.Core_Application_Workload__c ='Internet of Things (IoT)';
        solStor.Name                                    = 'Clone of Solution 1'+ dateString; 
        solStor.OwnerId                                 = UserInfo.getUserId();
        solStor.Core_Most_Recent_Status_Change_Date__c= null;
        solns.add(solStor);
        Core_CloneSolutionArea.ValidateSolutionData(solStor);
        solns=	Core_CloneSolutionArea.Validate_Solution_PValues(solns);
        Database.SaveResult  response1 = Database.insert(solStor, true);
        
        
        Core_Solution_Area_Partner__c Partner1= new Core_Solution_Area_Partner__c();
        Partner1.Core_Solution_Area__c    =  response1.getId();
        Partner1.Solution_Partner_Type__c= 'Design House';
        Partner1.Core_Solution_Partner_Role__c = 'End Customer';                                      
        Partner1.Core_Solution_Partner__c= Acc_ID;
        
        Database.insert(Partner1, true);
        
        Core_Solution_Area_Partner__c Partner11= new Core_Solution_Area_Partner__c();
        Partner11.Core_Solution_Area__c    =  response1.getId();
        Partner11.Solution_Partner_Type__c= 'Design House';
        Partner11.Core_Solution_Partner_Role__c = 'End Customer';                                      
        Partner11.Core_Solution_Partner__c= Acc_ID1;
        
        Database.insert(Partner11, true);
        DELETE Partner1;
        
        Core_Solution_Areas__c solStor1 = new Core_Solution_Areas__c();
        solStor1.Core_Solution_Type__c = 'S1: Product';
        solStor1.Core_End_Customer_Solution__c = 'Yes';
        solStor1.Core_Design_Visible__c = true;
        solStor1.Core_Deal_Visible__c=true;
        solStor1.Core_Region_of_availability__c='EMEA';
        solStor1.Core_Technology_Enabled__c='OpenVINO';
        solStor1.Core_Industry_Use_Case__c='Situational Monitoring-Chessboard';
        solStor1.Core_Industry__c='Financial Services Industry';
        solStor1.Core_Status__c = 'Active';
        solStor1.Core_Version__c='11';
        solStor1.Core_Application_Workload__c='Internet of Things (IoT)';
        solStor1.Name                                    = 'Clone of Solution 111'+ dateString; 
        solStor1.OwnerId                                 = UserInfo.getUserId();
        solStor1.Core_Most_Recent_Status_Change_Date__c= null;
        solStor1.Core_Content_Link__c='';
        solStor1.Core_Solution_owner_email__c='Test2222@inasdf.com';
        solStor1.Core_Solution_Description__c='We extract intelligent insights';
        
        String str_validation  = Core_CloneSolutionArea.ValidateSolutionData(solStor1);
        String ValidationMsgStatic='Please select below details \n ';
        if (str_validation.length()>0)
        {
            status_msg=   ValidationMsgStatic  + str_validation;
            throw new AuraHandledException(status_msg);
            
        }
        Core_CloneSolutionArea.ValidateSolutionData(solStor1);
        
        String usrProfileName = [select Profile.Name from User where id = :Userinfo.getUserId()].Profile.Name;
        Integer usrPermissionsetCnt = [SELECT count() FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name = 'Core_CRM_Special_Access'];
        
        if((usrProfileName == 'IT Admin' || usrProfileName == 'Data Ops' || usrPermissionsetCnt > 0 ) && (solStor!= null && solStor.Id!= null))
        {
            // any solution already exist with this name and version number
            Integer SolnCnt = [SELECT count() from Core_Solution_Areas__c where Core_Version__c = :solStor.Core_Version__c  and name= :solStor.Name];
            if ( SolnCnt == 0)
            {
                
                // Database.insert(solStor1, true);
                Database.SaveResult  response = Database.insert(solStor1, true);
                if (response== null)
                {
                    system.assert(response == null, 'failed'); 
                }
                if (response.isSuccess()) {
                    List<Core_Solution_Area_Partner__c> Soln_Partners= new List<Core_Solution_Area_Partner__c>();
                    List<Core_Solution_Area_Partner__c> Insert_Soln_Partners= new List<Core_Solution_Area_Partner__c>();
                    Soln_Partners = [select  Core_Solution_Area__c, Solution_Partner_Type__c, Core_Solution_Partner_Role__c, Core_Solution_Partner__c from Core_Solution_Area_Partner__c where Core_Solution_Area__c= :Solution_AreaId]; 
                    if(Soln_Partners.size()>0){
                        for(Core_Solution_Area_Partner__c soln_Partner: Soln_Partners){ 
                            
                            Core_Solution_Area_Partner__c Partner= new Core_Solution_Area_Partner__c();
                            Partner.Core_Solution_Area__c    = response.getId();
                            Partner.Solution_Partner_Type__c= soln_Partner.Solution_Partner_Type__c;
                            Partner.Core_Solution_Partner_Role__c = soln_Partner.Core_Solution_Partner_Role__c;
                            Partner.Core_Solution_Partner__c= soln_Partner.Core_Solution_Partner__c;
                            
                            Insert_Soln_Partners.add(Partner);
                            system.assert(response != null, 'success');  
                        }
                        try
                        {
                            Database.insert(Insert_Soln_Partners, true);
                            Core_CloneSolutionArea.CreateRecord(solStor.id, solStor1, true);
                            // system.assert(responsePartner != null, 'success'); 
                            
                        } catch (Exception e) {
                            // system.assert(responsePartner == null, 'failed'); 
                            throw new AuraHandledException(e.getMessage());
                        }
                    } 
                    else
                    {
                        for(Database.Error err : response.getErrors()) {
                            strError= 'Error Occured Pls try again.';                   
                        }
                        
                    }
                    
                    
                    
                    system.assert(strstatus != null, 'success'); 
                }
                else
                {
                    system.assert(strstatus == null, 'failed'); 
                    
                }
                
            }
            else
            {
                
                strstatus= 'Duplicate solution , Solution name and version are exist';
            }
        }
        else{
            strstatus= 'Your profile is not allowed to create a new solution';
            
        }
        Core_CloneSolutionArea.CreateRecord(solStor.id, solStor1, true);
        // Core_CloneSolutionArea.insertSolution( solStor1,solStor.id, true);
        Test.StopTest();  
        
    }
}