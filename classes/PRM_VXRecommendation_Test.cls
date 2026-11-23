@isTest
public class PRM_VXRecommendation_Test{
    public  static List<PRM_Value_Exchange_Recommendation__c> opidList = new List<PRM_Value_Exchange_Recommendation__c>();
    
    public testmethod static void duplicateRecommendationcheck(){
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdOPIDRec = Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByName().get('OPID Recommendation').getRecordTypeId();
        Id accountRTPartnerAccountGroup = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
        
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Johrt Rick';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_IPA_Partner_Role__c = 'Distributor';    
        newAccount.Core_CNDA_Number__c='';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        insert newAccount;
        
        Account a = new Account();//Account 
        a.RecordTypeId = accountRTPartnerAccountGroup;
        a.Name='Amazon';
        a.Core_PAG_Grouping_Method__c ='GLBL';
        insert a;
        
        Account newAccount1 = new Account();//Account
        newAccount1.RecordTypeId = recordTypeIdAccount;
        newAccount1.Name='Johrt Ricky';
        newAccount1.BillingCity='City';
        newAccount1.BillingStreet='Street';
        newAccount1.BillingCountry='India';
        newAccount1.BillingPostalCode='Postal code';
        newAccount1.Core_IPA_Partner_Role__c = 'Distributor';
        newAccount1.Core_CNDA_Number__c='';
        newAccount1.Core_Account_Type__c='Cloud Service Provider (CSP)';
        insert newAccount1;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        List<ChannelProgramLevel> cplList =new List<ChannelProgramLevel>();
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Member';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        Core_Account_Group_Member__c agm = new Core_Account_Group_Member__c(); 
        agm.Core_Partner_Account_Id__c = a.Id;
        agm.Core_Intel_Account_Id__c = newAccount.Id;
        agm.Core_MDA_Ind__c = true;
        agm.Core_Inactive_Ind__c = false;
        insert agm;
        
        PRM_Value_Exchange_Recommendation__c vxRecommnedation1 = new PRM_Value_Exchange_Recommendation__c();
        vxRecommnedation1.RecordTypeId=recordTypeIdOPIDRec;
        vxRecommnedation1.PRM_Account_Id__c=newAccount.Id;
        vxRecommnedation1.PRM_Tier_Id__c=cpl.Id;
        vxRecommnedation1.PRM_Recommendation_Status_Nm__c = 'In Process';
        vxRecommnedation1.PRM_Partner_Role_Nm__c='Solution Integrator';
        vxRecommnedation1.PRM_Market_Type_Nm__c='Mature';
        vxRecommnedation1.PRM_Grouping_Method_Nm__c='CTRY';
        vxRecommnedation1.PRM_Recommendation_Type_Nm__c='OPID';
        
        try{
            insert vxRecommnedation1; 
            
        }
        catch(Exception e){
            System.debug('OPID Already exists' +e.getMessage());
        }
        
        
        PRM_Value_Exchange_Recommendation__c vxRecommnedation2 = new PRM_Value_Exchange_Recommendation__c();
        vxRecommnedation2.RecordTypeId=recordTypeIdOPIDRec;
        vxRecommnedation2.PRM_Account_Id__c=newAccount1.Id;
        vxRecommnedation2.PRM_Tier_Id__c=cpl.Id;
        vxRecommnedation2.PRM_Partner_Role_Nm__c='Seller';
        vxRecommnedation2.PRM_Market_Type_Nm__c='Emerging';
        vxRecommnedation2.PRM_Recommendation_Status_Nm__c = 'In Process';
        vxRecommnedation2.PRM_Grouping_Method_Nm__c='GLBL';
        vxRecommnedation2.PRM_Recommendation_Type_Nm__c='OPID';
        insert vxRecommnedation2;
        
        PRM_Value_Exchange_Recommendation__c vxRecommnedation3 = new PRM_Value_Exchange_Recommendation__c();
        vxRecommnedation3.RecordTypeId=recordTypeIdOPIDRec;
        vxRecommnedation3.PRM_Account_Id__c=newAccount1.Id;
        vxRecommnedation3.PRM_Tier_Id__c=cpl.Id;
        vxRecommnedation3.PRM_Partner_Role_Nm__c='Distributor';
        vxRecommnedation3.PRM_Market_Type_Nm__c='Emerging';
        vxRecommnedation3.PRM_Recommendation_Status_Nm__c = 'In Process';
        vxRecommnedation3.PRM_Grouping_Method_Nm__c='CTRY';
        vxRecommnedation3.PRM_Recommendation_Type_Nm__c='OPID';
        try{
            insert vxRecommnedation3; 
        }
        catch(Exception e){
            System.debug('OPID Recommendation Already Exists' +e.getMessage());
        }
        
        system.assertEquals(recordTypeIdOPIDRec,vxRecommnedation2.RecordTypeId,'Value does not match');
    }
    
    public testmethod static void vxRecommendationUpdatecheck(){
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdOPIDRec = Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByName().get('OPID Recommendation').getRecordTypeId();
        
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Johrt Rick';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_IPA_Partner_Role__c = 'Distributor';    
        newAccount.Core_CNDA_Number__c='';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        insert newAccount;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        List<ChannelProgramLevel> cplList =new List<ChannelProgramLevel>();
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Member';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        PRM_Value_Exchange_Recommendation__c vxRecommnedation1 = new PRM_Value_Exchange_Recommendation__c();
        vxRecommnedation1.RecordTypeId=recordTypeIdOPIDRec;
        vxRecommnedation1.PRM_Account_Id__c=newAccount.Id;
        vxRecommnedation1.PRM_Tier_Id__c=cpl.Id;
        vxRecommnedation1.PRM_Recommendation_Status_Nm__c = 'In Process';
        vxRecommnedation1.PRM_Partner_Role_Nm__c='Solution Integrator';
        vxRecommnedation1.PRM_Market_Type_Nm__c='Mature';
        vxRecommnedation1.PRM_Recommendation_Type_Nm__c='OPID';
        try{
            insert vxRecommnedation1; 
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }
        
        
        PRM_Value_Exchange_Recommendation__c vxRecommnedation2 = new PRM_Value_Exchange_Recommendation__c();
        vxRecommnedation2.RecordTypeId=recordTypeIdOPIDRec;
        vxRecommnedation2.PRM_Account_Id__c=newAccount.Id;
        vxRecommnedation2.PRM_Tier_Id__c=cpl.Id;
        vxRecommnedation2.PRM_Recommendation_Status_Nm__c = 'In Process';
        vxRecommnedation2.PRM_Partner_Role_Nm__c='Solution Integrator';
        vxRecommnedation2.PRM_Market_Type_Nm__c='Mature';
        vxRecommnedation2.PRM_Grouping_Method_Nm__c='CTRY';
        vxRecommnedation2.PRM_Recommendation_Type_Nm__c='OPID';
        insert vxRecommnedation2;
        
        vxRecommnedation2.PRM_Grouping_Method_Nm__c='';
        try{
            update vxRecommnedation2;
        }
        catch(Exception e){
            System.debug('Update'+e.getMessage());
        }
        PRM_Value_Exchange_Recommendation__c vxRecommnedation3 = [Select PRM_Grouping_Method_Nm__c from PRM_Value_Exchange_Recommendation__c where Id=:vxRecommnedation2.Id];
        //system.assertEquals('CTRY',vxRecommnedation3.PRM_Grouping_Method_Nm__c,'Value should not be updated');
    }  
    
    
    public testmethod static void vxRecommendationUpdateOrCreateACM(){
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdPAGAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Id recordTypeIdOPIDRec = Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByName().get('OPID Recommendation').getRecordTypeId();
        
        
        Account newAccount = new Account();//Account
        // newAccount.RecordTypeId = recordTypeIdPAGAccount;
        newAccount.RecordTypeId =recordTypeIdAccount;
        newAccount.Name='David Miller';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_IPA_Partner_Role__c = 'Distributor';    
        newAccount.Core_CNDA_Number__c='';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        insert newAccount;
        
        Account pagAccount = new Account();//Account
        pagAccount.RecordTypeId =recordTypeIdPAGAccount;
        pagAccount.Name='John Miller';
        pagAccount.BillingCity='City';
        pagAccount.BillingStreet='Street';
        pagAccount.BillingCountry='India';
        pagAccount.BillingPostalCode='Postal code';
        pagAccount.Core_IPA_Partner_Role__c = 'Solution Integrator';    
        pagAccount.Core_CNDA_Number__c='';
        pagAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        insert pagAccount;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        List<ChannelProgramLevel> cplList =new List<ChannelProgramLevel>();
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Member';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
        cpl1.Name='Gold';
        cpl1.ProgramId=cp.Id;
        insert cpl1;
        
        
        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=pagAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cp.Id;
        acm.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm.PRM_Partner_Role__c='Solution Integrator';
        insert acm;
        
        PRM_AccountChannelMembership__c intelAccntACM = new PRM_AccountChannelMembership__c(); //Account Channel Membership
        intelAccntACM.PRM_Account_Id__c=newAccount.id;
        intelAccntACM.PRM_Status_Nm__c='Approved';
        intelAccntACM.PRM_Channel_Program_Id__c=cp.Id;
        intelAccntACM.PRM_Channel_Program_Level_Id__c=cpl.Id;
        intelAccntACM.PRM_Partner_Role__c='Solution Integrator';
        insert intelAccntACM;
        
        PRM_Value_Exchange_Recommendation__c opidRec = new PRM_Value_Exchange_Recommendation__c();
        opidRec.RecordTypeId=recordTypeIdOPIDRec;
        opidRec.PRM_Account_Id__c=newAccount.Id;
        opidRec.PRM_One_Partner_Id__c = pagAccount.Id;
        opidRec.PRM_Tier_Id__c=cpl.Id;
        opidRec.PRM_Recommendation_Status_Nm__c = 'In Process';
        opidRec.PRM_Partner_Role_Nm__c='Solution Integrator';
        opidRec.PRM_Market_Type_Nm__c='Mature';
        opidRec.PRM_Recommendation_Type_Nm__c='OPID';
        opidRec.PRM_Grouping_Method_Nm__c='CTRY';
        opidRec.PRM_Eligibility_Tier__c =cpl1.Id;
        
        Account newAccount1 = new Account();//Account
        newAccount1.RecordTypeId =recordTypeIdAccount;
        newAccount1.Name='George Miller';
        newAccount1.BillingCity='City';
        newAccount1.BillingStreet='Street';
        newAccount1.BillingCountry='India';
        newAccount1.BillingPostalCode='Postal code';
        newAccount1.Core_IPA_Partner_Role__c = 'Distributor';   
        newAccount1.Core_CNDA_Number__c='';
        newAccount1.Core_Account_Type__c='Cloud Service Provider (CSP)';
        insert newAccount1;
        
        PRM_Value_Exchange_Recommendation__c opidRec1 = new PRM_Value_Exchange_Recommendation__c();
        opidRec1.RecordTypeId=recordTypeIdOPIDRec;
        opidRec1.PRM_Account_Id__c=newAccount1.Id;
        opidRec1.PRM_Tier_Id__c=cpl.Id;
        opidRec1.PRM_Recommendation_Status_Nm__c = 'In Process';
        opidRec1.PRM_Partner_Role_Nm__c='FPGA Designer';
        opidRec1.PRM_Market_Type_Nm__c='Mature';
        opidRec1.PRM_Recommendation_Type_Nm__c='OPID';
        opidRec1.PRM_Grouping_Method_Nm__c='CTRY';
        opidRec1.PRM_Eligibility_Tier__c =cpl1.Id;
        
        try{
            insert opidRec;
            insert opidRec1; 
            opidList.add(opidRec);
            opidList.add(opidRec1);
            System.debug('OPID Rec Inserted');
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }
        for(PRM_Value_Exchange_Recommendation__c vxRec : opidList){
            vxRec.PRM_Recommendation_Status_Nm__c = 'In Process';
        }
        try{
            update opidList; 
            System.debug('OPID Rec Updated');
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }
        
        PRM_Value_Exchange_Recommendation__c vxRec = [Select PRM_Partner_Role_Nm__c from PRM_Value_Exchange_Recommendation__c where Id=:opidRec.Id];
        system.assertEquals('Solution Integrator',vxRec.PRM_Partner_Role_Nm__c,'Value should not be updated');
        map<Id,PRM_Value_Exchange_Recommendation__c> recmap=new map<Id,PRM_Value_Exchange_Recommendation__c>();
        recmap.put(opidRec.id,opidRec);
        System.debug('opidList->'+opidList);
        System.debug('recmap->'+recmap);
        System.debug('recordTypeIdOPIDRec->'+recordTypeIdOPIDRec);
        //PRM_VXRecommendation_Utility.duplicateRecommendationcheck(opidList,recmap,recordTypeIdOPIDRec);
        
    } 
    
    @isTest static void opidOutboundMssgtest(){
        
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdOPIDRec = Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByName().get('OPID Recommendation').getRecordTypeId();
        
        
        Account newAccount = new Account();//Account
        // newAccount.RecordTypeId = recordTypeIdPAGAccount;
        newAccount.RecordTypeId =recordTypeIdAccount;
        newAccount.Name='David Miller';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_IPA_Partner_Role__c = 'Distributor';    
        newAccount.Core_CNDA_Number__c='';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        insert newAccount;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Gold';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        list<Core_Integration_Outbound_Message__c> obmLst=new list<Core_Integration_Outbound_Message__c>();
        set<id> tagIds=new set<id>();
        
        Core_Integration_Outbound_Message__c obmsrec=new Core_Integration_Outbound_Message__c();
        obmsrec.Core_Tags__c=newAccount.id;
		obmsrec.Core_Status__c='Successful';
        obmsrec.Core_MessageType__c='OPID Request' ;
        tagIds.add(obmsrec.Core_Tags__c);
        obmLst.add(obmsrec);
        
        Core_Integration_Outbound_Message__c obmsrec1=new Core_Integration_Outbound_Message__c();
        obmsrec1.Core_Tags__c=newAccount.id;
		obmsrec1.Core_Status__c='Failed';
        obmsrec1.Core_MessageType__c='OPID Request' ;
        obmLst.add(obmsrec1);
        tagIds.add(obmsrec1.Core_Tags__c);
		insert obmLst;  
          
        test.startTest();
        PRM_VXRecommendation_Utility.statusCheck(tagIds);
        test.stopTest();
        //system.assertEquals(newAccount.PRM_Partner_Role_Nm__c,'Solution Integrator','Value should not be updated');
    }
    
    public testmethod static void updateTierOnVxData(){
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeUpgrade = Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByName().get(System.Label.PRM_RecordType_Upgrade_Downgrade).getRecordTypeId();         
        Id recordTypeIdPAGAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Id recordTypeIdOPIDRec = Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByName().get('OPID Recommendation').getRecordTypeId();
        
        Test.startTest();
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Johrt Rick';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_IPA_Partner_Role__c = 'Distributor';    
        newAccount.Core_CNDA_Number__c='';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        insert newAccount;
        
        Account pagAccount = new Account();//Account
        pagAccount.RecordTypeId =recordTypeIdPAGAccount;
        pagAccount.Name='John Miller';
        pagAccount.BillingCity='City';
        pagAccount.BillingStreet='Street';
        pagAccount.BillingCountry='India';
        pagAccount.BillingPostalCode='Postal code';
        pagAccount.Core_IPA_Partner_Role__c = 'Solution Integrator';    
        pagAccount.Core_CNDA_Number__c='';
        pagAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        insert pagAccount;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        List<ChannelProgramLevel> cplList =new List<ChannelProgramLevel>();
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Member';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
        cpl1.Name='Gold';
        cpl1.ProgramId=cp.Id;
        insert cpl1;
        
        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=pagAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cp.Id;
        acm.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm.PRM_Partner_Role__c='Solution Integrator';
        insert acm;
        
        PRM_Value_Exchange_Data__c vxData = new PRM_Value_Exchange_Data__c();
        vxData.PRM_Account_Id__c=newAccount.Id;
        vxData.PRM_One_Partner_Id__c=pagAccount.Id;
        vxData.PRM_Tier_Id__c=cpl.Id;
        vxData.PRM_Partner_Role_Nm__c='Solution Integrator';
        vxData.PRM_Country_Market_Type_Nm__c='NA';
        vxData.PRM_Change_Date_Dt__c=Date.Today();
        vxData.PRM_From_Dt__c=Date.Today();
        vxData.PRM_To_Dt__c=Date.Today()+10;
        vxData.PRM_Processed_Date_Time_Dt__c=Date.Today();
        insert vxData;
        
        PRM_Value_Exchange_Recommendation__c vxRecommnedation1 = new PRM_Value_Exchange_Recommendation__c();
        vxRecommnedation1.RecordTypeId=recordTypeIdOPIDRec ;
        vxRecommnedation1.PRM_Account_Id__c=newAccount.Id;
        vxRecommnedation1.PRM_One_Partner_Id__c=pagAccount.Id;
        vxRecommnedation1.PRM_Tier_Id__c=cpl.Id;
        vxRecommnedation1.PRM_Recommendation_Status_Nm__c = 'In Process';
        vxRecommnedation1.PRM_Partner_Role_Nm__c='Solution Integrator';
        vxRecommnedation1.PRM_Market_Type_Nm__c='NA';
        vxRecommnedation1.PRM_Recommendation_Type_Nm__c='OPID';
        vxRecommnedation1.PRM_Eligibility_Tier__c=cpl1.Id;
        vxRecommnedation1.PRM_Grouping_Method_Nm__c ='CTRY';
        insert vxRecommnedation1;
         
        vxRecommnedation1.RecordTypeId=recordTypeUpgrade;
        vxRecommnedation1.PRM_Recommendation_Status_Nm__c='Processed';
        vxRecommnedation1.PRM_Recommendation_Type_Nm__c='Upgrade';

        try{
            update vxRecommnedation1;
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }
        vxRecommnedation1.PRM_Recommendation_Status_Nm__c='In Process';
        try{
            update vxRecommnedation1;
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }
        
        vxRecommnedation1.PRM_Recommendation_Status_Nm__c='failed to Submit for OPID';
        try{
            update vxRecommnedation1;
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }
        PRM_VXRecommendation_Utility.getOPID_Ids(vxRecommnedation1.Id);
        
        vxRecommnedation1.PRM_Recommendation_Status_Nm__c='Failed';
        try{
            update vxRecommnedation1;
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }        
        PRM_VXRecommendation_Utility.getOPID_Ids(vxRecommnedation1.Id);      
      
        Test.stopTest();
        PRM_Value_Exchange_Data__c vxDataRec= [Select PRM_Tier_Id__r.Name from PRM_Value_Exchange_Data__c where Id=:vxData.Id];
        //system.assertEquals('Gold',vxDataRec.PRM_Tier_Id__r.Name ,'Tier Value of VXData should be updated'); 
    }   
    public testmethod static void vxRecommendationTest(){
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeUpgrade = Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByName().get(System.Label.PRM_RecordType_Upgrade_Downgrade).getRecordTypeId();         
        Id recordTypeIdPAGAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Id recordTypeIdOPIDRec = Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByName().get('OPID Recommendation').getRecordTypeId();
        
        Test.startTest();
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Johrt Rick';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_IPA_Partner_Role__c = 'Distributor';    
        newAccount.Core_CNDA_Number__c='';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        insert newAccount;
        
        Account pagAccount = new Account();//Account
        pagAccount.RecordTypeId =recordTypeIdPAGAccount;
        pagAccount.Name='John Miller';
        pagAccount.BillingCity='City';
        pagAccount.BillingStreet='Street';
        pagAccount.BillingCountry='India';
        pagAccount.BillingPostalCode='Postal code';
        pagAccount.Core_IPA_Partner_Role__c = 'Solution Integrator';    
        pagAccount.Core_CNDA_Number__c='';
        pagAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        insert pagAccount;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        List<ChannelProgramLevel> cplList =new List<ChannelProgramLevel>();
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Member';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
        cpl1.Name='Gold';
        cpl1.ProgramId=cp.Id;
        insert cpl1;
        
        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=pagAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cp.Id;
        acm.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm.PRM_Partner_Role__c='Solution Integrator';
        insert acm;
        
        newAccount.Core_CIM_ID__c = '123345670';
        
        Update newAccount;
        
        PRM_Value_Exchange_Data__c vxData = new PRM_Value_Exchange_Data__c();
        vxData.PRM_Account_Id__c=newAccount.Id;
        vxData.PRM_One_Partner_Id__c=pagAccount.Id;
        vxData.PRM_Tier_Id__c=cpl.Id;
        vxData.PRM_Partner_Role_Nm__c='Solution Integrator';
        vxData.PRM_Country_Market_Type_Nm__c='NA';
        vxData.PRM_Change_Date_Dt__c=Date.Today();
        vxData.PRM_From_Dt__c=Date.Today();
        vxData.PRM_To_Dt__c=Date.Today()+10;
        vxData.PRM_Processed_Date_Time_Dt__c=Date.Today();
        insert vxData;
        
        PRM_Value_Exchange_Recommendation__c vxRecommnedation1 = new PRM_Value_Exchange_Recommendation__c();
        vxRecommnedation1.RecordTypeId=recordTypeIdOPIDRec ;
        vxRecommnedation1.PRM_Account_Id__c=newAccount.Id;
        vxRecommnedation1.PRM_One_Partner_Id__c=pagAccount.Id;
        vxRecommnedation1.PRM_Tier_Id__c=cpl.Id;
        vxRecommnedation1.PRM_Recommendation_Status_Nm__c = 'In Process';
        vxRecommnedation1.PRM_Partner_Role_Nm__c='Solution Integrator';
        vxRecommnedation1.PRM_Market_Type_Nm__c='NA';
        vxRecommnedation1.PRM_Recommendation_Type_Nm__c='OPID';
        vxRecommnedation1.PRM_Eligibility_Tier__c=cpl1.Id;
        vxRecommnedation1.PRM_Grouping_Method_Nm__c ='CTRY';
        insert vxRecommnedation1;
        
        vxRecommnedation1.PRM_Recommendation_Status_Nm__c='failed to Submit for OPID';
        try{
            update vxRecommnedation1;
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }
        PRM_VXRecommendation_Utility.getOPID_Ids(vxRecommnedation1.Id);
        
        vxRecommnedation1.PRM_Recommendation_Status_Nm__c='Failed';
        try{
            update vxRecommnedation1;
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }  
        List <Core_Integration_Outbound_Message__c> lstOfoutBoundMsg = [SELECT Id, Core_Status__c, Core_Tags__c, Core_Payload__c,
                                                                        Core_MessageType__c
                                                                        FROM Core_Integration_Outbound_Message__c 
                                                                        WHERE Core_MessageType__c = 'OPID Request'];
        
        delete lstOfoutBoundMsg;
        
        PRM_VXRecommendation_Utility.getOPID_Ids(vxRecommnedation1.Id);      
        
        Test.stopTest();
    }
    
    public testmethod static void updateTierOnVxData1(){
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeUpgrade = Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByName().get(System.Label.PRM_RecordType_Upgrade_Downgrade).getRecordTypeId();         
        Id recordTypeIdPAGAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Id recordTypeIdOPIDRec = Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByName().get('OPID Recommendation').getRecordTypeId();
        
        Test.startTest();
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Johrt Rick';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_IPA_Partner_Role__c = 'Distributor';    
        newAccount.Core_CNDA_Number__c='';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        insert newAccount;
        
        Contact con = new contact();
        con.LastName='Testxyz';
        con.FirstName='Testxyz';
        con.AccountId = newAccount.id;
        con.Email ='test@xuc.com';
        con.MailingCountry='USA';
        Insert con;
        PRM_ContactRelationships__c pcr  = new PRM_ContactRelationships__c();
        
        pcr.Name = 'Employee';
        pcr.PRM_Contact_Relationship_Cd__c ='WORKSFOR';
        insert pcr;

        PRM_Account_Contact_Relationship__c acr = new PRM_Account_Contact_Relationship__c();
        
        acr.PRM_Account_Id__c = newAccount.id;
        acr.PRM_Contact_Id__c = con.Id;
        acr.PRM_Relationship_Id__c = pcr.Id;
        acr.PRM_Status_Nm__c = 'Complete';
        insert acr;
      
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        List<ChannelProgramLevel> cplList =new List<ChannelProgramLevel>();
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Member';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
        cpl1.Name='Gold';
        cpl1.ProgramId=cp.Id;
        insert cpl1;
        
        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=newAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cp.Id;
        acm.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm.PRM_Partner_Role__c='Solution Integrator';
        insert acm;
        
        newAccount.Core_CIM_ID__c = '123345670';
        
        Update newAccount;
        
        
        PRM_Value_Exchange_Recommendation__c opidRec = new PRM_Value_Exchange_Recommendation__c();
        opidRec.RecordTypeId=recordTypeIdOPIDRec;
        opidRec.PRM_Account_Id__c=newAccount.Id;
        opidRec.PRM_Tier_Id__c=cpl.Id;
        opidRec.PRM_Recommendation_Status_Nm__c = 'In Process';
        opidRec.PRM_Partner_Role_Nm__c='Solution Integrator';
        opidRec.PRM_Market_Type_Nm__c='Mature';
        opidRec.PRM_Recommendation_Type_Nm__c='OPID';
        opidRec.PRM_Grouping_Method_Nm__c='CTRY';
        insert opidRec;
        list<Core_Integration_Outbound_Message__c> obmLst=new list<Core_Integration_Outbound_Message__c>();
        
        Core_Integration_Outbound_Message__c obmsrec=new Core_Integration_Outbound_Message__c();
        obmsrec.Core_Tags__c=opidRec.id;
		obmsrec.Core_Status__c='Successful';
        obmsrec.Core_MessageType__c='OPID Request' ;
        obmLst.add(obmsrec);
        
        Core_Integration_Outbound_Message__c obmsrec1=new Core_Integration_Outbound_Message__c();
        obmsrec1.Core_Tags__c=opidRec.id;
        obmsrec1.Core_Status__c='Successful';
        obmsrec1.Core_MessageType__c='OPID Request' ;
        obmLst.add(obmsrec1);
        
        insert obmLst;
        Set<Id> setOfIds = new Set<Id>();
        setOfIds.add(opidRec.id);
        
        PRM_VXRecommendation_Utility.statusCheck(setOfIds);
        
        Test.stopTest();
    }
    
    
    public testmethod static void updateVxRecExample(){
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeUpgrade = Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByName().get(System.Label.PRM_RecordType_Upgrade_Downgrade).getRecordTypeId();         
        Id recordTypeIdPAGAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Id recordTypeIdOPIDRec = Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByName().get('OPID Recommendation').getRecordTypeId();
        
        Test.startTest();
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Johrt Rick';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_IPA_Partner_Role__c = 'Distributor';    
        newAccount.Core_CNDA_Number__c='';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        insert newAccount;
        
        Contact con = new contact();
        con.LastName='Testxyz';
        con.FirstName='Testxyz';
        con.AccountId = newAccount.id;
        con.Email ='test@xuc.com';
        con.MailingCountry='USA';
        Insert con;
        PRM_ContactRelationships__c pcr  = new PRM_ContactRelationships__c();
        
        pcr.Name = 'Employee';
        pcr.PRM_Contact_Relationship_Cd__c ='WORKSFOR';
        insert pcr;

        PRM_Account_Contact_Relationship__c acr = new PRM_Account_Contact_Relationship__c();
        
        acr.PRM_Account_Id__c = newAccount.id;
        acr.PRM_Contact_Id__c = con.Id;
        acr.PRM_Relationship_Id__c = pcr.Id;
        acr.PRM_Status_Nm__c = 'Complete';
        insert acr;
      
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        List<ChannelProgramLevel> cplList =new List<ChannelProgramLevel>();
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Member';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
        cpl1.Name='Gold';
        cpl1.ProgramId=cp.Id;
        insert cpl1;
        
        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=newAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cp.Id;
        acm.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm.PRM_Partner_Role__c='Solution Integrator';
        insert acm;
        
        newAccount.Core_CIM_ID__c = '123345670';
        
        Update newAccount;
        
        
        PRM_Value_Exchange_Recommendation__c opidRec = new PRM_Value_Exchange_Recommendation__c();
        opidRec.RecordTypeId=recordTypeIdOPIDRec;
        opidRec.PRM_Account_Id__c=newAccount.Id;
        opidRec.PRM_Tier_Id__c=cpl.Id;
        opidRec.PRM_Recommendation_Status_Nm__c = 'In Process';
        opidRec.PRM_Partner_Role_Nm__c='Solution Integrator';
        opidRec.PRM_Market_Type_Nm__c='Mature';
        opidRec.PRM_Recommendation_Type_Nm__c='OPID';
        opidRec.PRM_Grouping_Method_Nm__c='CTRY';
        
        insert opidRec;
        
        list<Core_Integration_Outbound_Message__c> obmLst = new list<Core_Integration_Outbound_Message__c>();
        
        Core_Integration_Outbound_Message__c obmsrec = new Core_Integration_Outbound_Message__c();
        obmsrec.Core_Tags__c = opidRec.id;
		obmsrec.Core_Status__c = 'Successful';
        obmsrec.Core_MessageType__c = 'OPID Request' ;
        obmLst.add(obmsrec);
        
        Core_Integration_Outbound_Message__c obmsrec1 = new Core_Integration_Outbound_Message__c();
        obmsrec1.Core_Tags__c = opidRec.id;
        obmsrec1.Core_Status__c = 'Failed';
        obmsrec1.Core_MessageType__c = 'OPID Request' ;
        obmLst.add(obmsrec1);
        
        insert obmLst;
        Set<Id> setOfIds = new Set<Id>();
        setOfIds.add(opidRec.id);
        
        PRM_VXRecommendation_Utility.statusCheck(setOfIds);
        
        Test.stopTest();
    }
    
    
    public testmethod static void updateVxRecExample1(){
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeUpgrade = Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByName().get(System.Label.PRM_RecordType_Upgrade_Downgrade).getRecordTypeId();         
        Id recordTypeIdPAGAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Id recordTypeIdOPIDRec = Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByName().get('OPID Recommendation').getRecordTypeId();
        
        Test.startTest();
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Johrt Rick';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_IPA_Partner_Role__c = 'Distributor';    
        newAccount.Core_CNDA_Number__c='';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        insert newAccount;
        
        Contact con = new contact();
        con.LastName='Testxyz';
        con.FirstName='Testxyz';
        con.AccountId = newAccount.id;
        con.Email ='test@xuc.com';
        con.MailingCountry='USA';
        Insert con;
        PRM_ContactRelationships__c pcr  = new PRM_ContactRelationships__c();
        
        pcr.Name = 'Employee';
        pcr.PRM_Contact_Relationship_Cd__c ='WORKSFOR';
        insert pcr;

        PRM_Account_Contact_Relationship__c acr = new PRM_Account_Contact_Relationship__c();
        
        acr.PRM_Account_Id__c = newAccount.id;
        acr.PRM_Contact_Id__c = con.Id;
        acr.PRM_Relationship_Id__c = pcr.Id;
        acr.PRM_Status_Nm__c = 'Complete';
        insert acr;
      
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        List<ChannelProgramLevel> cplList =new List<ChannelProgramLevel>();
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Member';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
        cpl1.Name='Gold';
        cpl1.ProgramId=cp.Id;
        insert cpl1;
        
        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=newAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cp.Id;
        acm.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm.PRM_Partner_Role__c='Solution Integrator';
        insert acm;
        
        newAccount.Core_CIM_ID__c = '123345670';
        
        Update newAccount;
        
        
        PRM_Value_Exchange_Recommendation__c opidRec = new PRM_Value_Exchange_Recommendation__c();
        opidRec.RecordTypeId=recordTypeIdOPIDRec;
        opidRec.PRM_Account_Id__c=newAccount.Id;
        opidRec.PRM_Tier_Id__c=cpl.Id;
        opidRec.PRM_Recommendation_Status_Nm__c = 'In Process';
        opidRec.PRM_Partner_Role_Nm__c='Solution Integrator';
        opidRec.PRM_Market_Type_Nm__c='Mature';
        opidRec.PRM_Recommendation_Type_Nm__c='OPID';
        opidRec.PRM_Grouping_Method_Nm__c='CTRY';
        
        insert opidRec;
        
        list<Core_Integration_Outbound_Message__c> obmLst = new list<Core_Integration_Outbound_Message__c>();
        
        Core_Integration_Outbound_Message__c obmsrec = new Core_Integration_Outbound_Message__c();
        obmsrec.Core_Tags__c = opidRec.id;
		obmsrec.Core_Status__c = 'Successful';
        obmsrec.Core_MessageType__c = 'OPID Request' ;
        obmLst.add(obmsrec);
        
        Core_Integration_Outbound_Message__c obmsrec1 = new Core_Integration_Outbound_Message__c();
        obmsrec1.Core_Tags__c = opidRec.id;
        obmsrec1.Core_Status__c = 'Failed';
        obmsrec1.Core_MessageType__c = 'OPID Request' ;
        obmLst.add(obmsrec1);
        
        insert obmLst;
        Set<Id> setOfIds = new Set<Id>();
        setOfIds.add(opidRec.id);
        
        List<PRM_Tracker__c> trackerList = new List<PRM_Tracker__c>();
         
        PRM_Tracker__c inprogressTracker  = PRM_IPA_Utility.createTrackerInstance('OPID Recommendation', 'IN_PRGS', opidRec.Id, opidRec.PRM_Account_Id__c, null, null, null, false, null, null,null );    
        trackerList.add(inprogressTracker); 
        PRM_Tracker__c opidSubTracker  = PRM_IPA_Utility.createTrackerInstance('OPID Recommendation', 'OPID_SUBMITTED', opidRec.Id, opidRec.PRM_Account_Id__c, null, null, null, false, null, null,null );    
        trackerList.add(opidSubTracker);
        PRM_Tracker__c muletracker  = PRM_IPA_Utility.createTrackerInstance('OPID Recommendation','MULESOFT_ACK', opidRec.Id, opidRec.PRM_Account_Id__c, null, null, null, false, null, null, null );    
        trackerList.add(muletracker); 

        insert trackerList;
        PRM_VXRecommendation_Utility.statusCheck(setOfIds);
        
        Test.stopTest();
    }
    
    
     public testmethod static void updateVxRecExample2(){
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeUpgrade = Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByName().get(System.Label.PRM_RecordType_Upgrade_Downgrade).getRecordTypeId();         
        Id recordTypeIdPAGAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Id recordTypeIdOPIDRec = Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByName().get('OPID Recommendation').getRecordTypeId();
        
        Test.startTest();
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Johrt Rick';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_IPA_Partner_Role__c = 'Distributor';    
        newAccount.Core_CNDA_Number__c='';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        insert newAccount;
        
        Contact con = new contact();
        con.LastName='Testxyz';
        con.FirstName='Testxyz';
        con.AccountId = newAccount.id;
        con.Email ='test@xuc.com';
        con.MailingCountry='USA';
        Insert con;
        PRM_ContactRelationships__c pcr  = new PRM_ContactRelationships__c();
        
        pcr.Name = 'Employee';
        pcr.PRM_Contact_Relationship_Cd__c ='WORKSFOR';
        insert pcr;

        PRM_Account_Contact_Relationship__c acr = new PRM_Account_Contact_Relationship__c();
        
        acr.PRM_Account_Id__c = newAccount.id;
        acr.PRM_Contact_Id__c = con.Id;
        acr.PRM_Relationship_Id__c = pcr.Id;
        acr.PRM_Status_Nm__c = 'Complete';
        insert acr;
      
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        List<ChannelProgramLevel> cplList =new List<ChannelProgramLevel>();
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Member';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
        cpl1.Name='Gold';
        cpl1.ProgramId=cp.Id;
        insert cpl1;
        
        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=newAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cp.Id;
        acm.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm.PRM_Partner_Role__c='Solution Integrator';
        insert acm;
        
        newAccount.Core_CIM_ID__c = '123345670';
        
        Update newAccount;
        
        
        PRM_Value_Exchange_Recommendation__c opidRec = new PRM_Value_Exchange_Recommendation__c();
        opidRec.RecordTypeId=recordTypeIdOPIDRec;
        opidRec.PRM_Account_Id__c=newAccount.Id;
        opidRec.PRM_Tier_Id__c=cpl.Id;
        opidRec.PRM_Recommendation_Status_Nm__c = 'In Process';
        opidRec.PRM_Partner_Role_Nm__c='Solution Integrator';
        opidRec.PRM_Market_Type_Nm__c='Mature';
        opidRec.PRM_Recommendation_Type_Nm__c='OPID';
        opidRec.PRM_Grouping_Method_Nm__c='CTRY';
        
        insert opidRec;
        
        list<Core_Integration_Outbound_Message__c> obmLst = new list<Core_Integration_Outbound_Message__c>();
        
        Core_Integration_Outbound_Message__c obmsrec = new Core_Integration_Outbound_Message__c();
        obmsrec.Core_Tags__c = opidRec.id;
		obmsrec.Core_Status__c = 'Successful';
        obmsrec.Core_MessageType__c = 'OPID Request' ;
        obmLst.add(obmsrec);
        
        Core_Integration_Outbound_Message__c obmsrec1 = new Core_Integration_Outbound_Message__c();
        obmsrec1.Core_Tags__c = opidRec.id;
        obmsrec1.Core_Status__c = 'Successful';
        obmsrec1.Core_MessageType__c = 'OPID Request' ;
        obmLst.add(obmsrec1);
        
        insert obmLst;
        Set<Id> setOfIds = new Set<Id>();
        setOfIds.add(opidRec.id);
        
        List<PRM_Tracker__c> trackerList = new List<PRM_Tracker__c>();
         
        PRM_Tracker__c inprogressTracker  = PRM_IPA_Utility.createTrackerInstance('OPID Recommendation', 'IN_PRGS', opidRec.Id, opidRec.PRM_Account_Id__c, null, null, null, false, null, null,null );    
        trackerList.add(inprogressTracker); 
        PRM_Tracker__c opidSubTracker  = PRM_IPA_Utility.createTrackerInstance('OPID Recommendation', 'OPID_SUBMITTED', opidRec.Id, opidRec.PRM_Account_Id__c, null, null, null, false, null, null ,null);    
        trackerList.add(opidSubTracker);
        PRM_Tracker__c muletracker  = PRM_IPA_Utility.createTrackerInstance('OPID Recommendation','MULESOFT_ACK', opidRec.Id, opidRec.PRM_Account_Id__c, null, null, null, false, null, null,null );    
        trackerList.add(muletracker); 

        insert trackerList;
        PRM_VXRecommendation_Utility.statusCheck(setOfIds);
        
        Test.stopTest();
    }
    
    
    
    public testmethod static void updateVxRecExample3(){
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeUpgrade = Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByName().get(System.Label.PRM_RecordType_Upgrade_Downgrade).getRecordTypeId();         
        Id recordTypeIdPAGAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Id recordTypeIdOPIDRec = Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByName().get('OPID Recommendation').getRecordTypeId();
        
        Test.startTest();
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Johrt Rick';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_IPA_Partner_Role__c = 'Distributor';    
        newAccount.Core_CNDA_Number__c='';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        insert newAccount;
        
        Contact con = new contact();
        con.LastName='Testxyz';
        con.FirstName='Testxyz';
        con.AccountId = newAccount.id;
        con.Email ='test@xuc.com';
        con.MailingCountry='USA';
        Insert con;
        PRM_ContactRelationships__c pcr  = new PRM_ContactRelationships__c();
        
        pcr.Name = 'Employee';
        pcr.PRM_Contact_Relationship_Cd__c ='WORKSFOR';
        insert pcr;

        PRM_Account_Contact_Relationship__c acr = new PRM_Account_Contact_Relationship__c();
        
        acr.PRM_Account_Id__c = newAccount.id;
        acr.PRM_Contact_Id__c = con.Id;
        acr.PRM_Relationship_Id__c = pcr.Id;
        acr.PRM_Status_Nm__c = 'Complete';
        insert acr;
      
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        List<ChannelProgramLevel> cplList =new List<ChannelProgramLevel>();
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Member';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
        cpl1.Name='Gold';
        cpl1.ProgramId=cp.Id;
        insert cpl1;
        
        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=newAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cp.Id;
        acm.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm.PRM_Partner_Role__c='Solution Integrator';
        insert acm;
        
        newAccount.Core_CIM_ID__c = '123345670';
        
        Update newAccount;
        
        
        PRM_Value_Exchange_Recommendation__c opidRec = new PRM_Value_Exchange_Recommendation__c();
        opidRec.RecordTypeId=recordTypeIdOPIDRec;
        opidRec.PRM_Account_Id__c=newAccount.Id;
        opidRec.PRM_Tier_Id__c=cpl.Id;
        opidRec.PRM_Recommendation_Status_Nm__c = 'In Process';
        opidRec.PRM_Partner_Role_Nm__c='Solution Integrator';
        opidRec.PRM_Market_Type_Nm__c='Mature';
        opidRec.PRM_Recommendation_Type_Nm__c='OPID';
        opidRec.PRM_Grouping_Method_Nm__c='CTRY';
        
        insert opidRec;
        
        list<Core_Integration_Outbound_Message__c> obmLst = new list<Core_Integration_Outbound_Message__c>();
        
        Core_Integration_Outbound_Message__c obmsrec = new Core_Integration_Outbound_Message__c();
        obmsrec.Core_Tags__c = opidRec.id;
		obmsrec.Core_Status__c = 'Successful';
        obmsrec.Core_MessageType__c = 'OPID Request' ;
        obmLst.add(obmsrec);
        
        Core_Integration_Outbound_Message__c obmsrec1 = new Core_Integration_Outbound_Message__c();
        obmsrec1.Core_Tags__c = opidRec.id;
        obmsrec1.Core_Status__c = 'Successful';
        obmsrec1.Core_MessageType__c = 'OPID Request' ;
        obmLst.add(obmsrec1);
        
        insert obmLst;
        
        Core_OnePartner_Inbound_Message__c inboundMsg = new Core_OnePartner_Inbound_Message__c();
        inboundMsg.Core_SalesCloud_AccountID__c = opidRec.PRM_Account_Id__c;
        inboundMsg.Core_Status__c ='PROCESSED';
        inboundMsg.Core_OnePartnerID__c = 121322;
        
        insert inboundMsg;
        opidRec.PRM_Recommendation_Status_Nm__c='failed to Submit for OPID';
        Update opidRec;
        
        PRM_VXRecommendation_Utility.getOPID_Ids(opidRec.Id);
       
        Test.stopTest();
    }
}