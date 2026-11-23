@isTest
public class IPAMembershipUtilityTest {
    @isTest static void testIPAMembershipRecords(){
        try{
            TEST.startTest();
            Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();        
            Account newAccount = new Account();//Account
            newAccount.RecordTypeId = recordTypeIdAccount;
            newAccount.Name='Greg Thomas';
            newAccount.BillingCity='City';
            newAccount.BillingStreet='Street';
            newAccount.BillingCountry='India';
            newAccount.BillingPostalCode='Postal code';
            newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
            insert newAccount;
            
            ChannelProgram cp = new ChannelProgram(); //Channel Program
            cp.Name='Intel Partner Alliance';
            cp.PRM_programCode__c='IPA';
            insert cp;
            
            ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
            cpl.Name='Titanium';
            cpl.ProgramId=cp.Id;
            insert cpl;
            
            ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
            cpl1.Name='Member';
            cpl1.ProgramId=cp.Id;
            insert cpl1;
            
            ChannelProgramLevel cpl2=new ChannelProgramLevel(); //Channel Program Level
            cpl2.Name='Gold';
            cpl2.ProgramId=cp.Id;
            insert cpl2;
            
            PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
            acm.PRM_Account_Id__c=newAccount.id;
            acm.PRM_Status_Nm__c='Approved';
            acm.PRM_Channel_Program_Id__c=cp.Id;
            acm.PRM_Channel_Program_Level_Id__c=cpl1.Id;
            acm.PRM_Partner_Role__c='Service Provider';
            insert acm;
            
            PRM_IPA_Membership__c membership = new PRM_IPA_Membership__c();
            membership.PRM_Account_Channel_Membership__c = acm.id;
            membership.PRM_Partner_Role__c = 'Distributor';
            membership.PRM_Partner_Tier__c=cpl2.Id;
            membership.PRM_Status__c= 'Pending';
            insert membership;
            
            PRM_IPA_Membership__c membership1 = new PRM_IPA_Membership__c();
            membership1.PRM_Account_Channel_Membership__c = acm.id;
            membership1.PRM_Partner_Role__c = 'Distributor';
            membership1.PRM_Partner_Tier__c=cpl2.Id;
            membership1.PRM_Status__c= 'Pending';
            insert membership1;
            
            PRM_AccountChannelMembership__c acm1= new PRM_AccountChannelMembership__c(); //Account Channel Membership
            acm1.PRM_Account_Id__c=newAccount.id;
            acm1.PRM_Status_Nm__c='Approved';
            acm1.PRM_Channel_Program_Id__c=cp.Id;
            acm1.PRM_Channel_Program_Level_Id__c=cpl1.Id;
            acm1.PRM_Partner_Role__c='manufacturer';
            insert acm1;
            
            PRM_IPA_Membership__c membership2 = new PRM_IPA_Membership__c();
            membership2.PRM_Account_Channel_Membership__c = acm.id;
            membership2.PRM_Partner_Role__c = 'manufacturer';
            membership2.PRM_Partner_Tier__c=cpl2.Id;
            membership2.PRM_Status__c= 'Pending';
            insert membership2;
            TEST.stopTest();
        }catch(Exception ex){
            //System.debug('Ex -->'+ex.getMessage());
        }
        
    }
    @isTest static void testIPAMembershipRecords2(){
        try{
            
            Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();        
            Account newAccount = new Account();//Account
            newAccount.RecordTypeId = recordTypeIdAccount;
            newAccount.Name='Greg Thomas';
            newAccount.BillingCity='City';
            newAccount.BillingStreet='Street';
            newAccount.BillingCountry='India';
            newAccount.BillingPostalCode='Postal code';
            newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
            insert newAccount;
            
            ChannelProgram cp = new ChannelProgram(); //Channel Program
            cp.Name='Intel Partner Alliance';
            cp.PRM_programCode__c='IPA';
            insert cp;
            
            ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
            cpl.Name='Titanium';
            cpl.ProgramId=cp.Id;
            insert cpl;
            
            ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
            cpl1.Name='Member';
            cpl1.ProgramId=cp.Id;
            insert cpl1;
            
            ChannelProgramLevel cpl2=new ChannelProgramLevel(); //Channel Program Level
            cpl2.Name='Gold';
            cpl2.ProgramId=cp.Id;
            insert cpl2;
            
            PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
            acm.PRM_Account_Id__c=newAccount.id;
            acm.PRM_Status_Nm__c='Approved';
            acm.PRM_Channel_Program_Id__c=cp.Id;
            acm.PRM_Channel_Program_Level_Id__c=cpl1.Id;
            acm.PRM_Partner_Role__c='Service Provider';
            
           insert acm;
            
            
            
            
            
            PRM_IPA_Membership__c membership11 = new PRM_IPA_Membership__c();
            membership11.PRM_Account_Channel_Membership__c = acm.id;
            membership11.PRM_Partner_Role__c = 'Seller';
            membership11.PRM_Partner_Tier__c=cpl2.Id;
            membership11.PRM_Status__c= 'Pending';
            insert membership11;
            
            PRM_IPA_Membership__c membership = new PRM_IPA_Membership__c();
            membership.PRM_Account_Channel_Membership__c = acm.id;
            membership.PRM_Partner_Role__c = 'Seller';
            membership.PRM_Partner_Tier__c=cpl1.Id;
            membership.PRM_Status__c= 'Pending';
            insert membership;
            
            
        }catch(Exception ex){
            //System.debug('Ex -->'+ex.getMessage());
        }
        
    }
    @isTest static void testIPAMembershipRecords3(){
        try{
            
            Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();        
            Account newAccount = new Account();//Account
            newAccount.RecordTypeId = recordTypeIdAccount;
            newAccount.Name='Greg Thomas';
            newAccount.BillingCity='City';
            newAccount.BillingStreet='Street';
            newAccount.BillingCountry='India';
            newAccount.BillingPostalCode='Postal code';
            newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
            insert newAccount;
            
            ChannelProgram cp = new ChannelProgram(); //Channel Program
            cp.Name='Intel Partner Alliance';
            cp.PRM_programCode__c='IPA';
            insert cp;
            
            ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
            cpl.Name='Titanium';
            cpl.ProgramId=cp.Id;
            insert cpl;
            
            ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
            cpl1.Name='Member';
            cpl1.ProgramId=cp.Id;
            insert cpl1;
            
            ChannelProgramLevel cpl2=new ChannelProgramLevel(); //Channel Program Level
            cpl2.Name='Gold';
            cpl2.ProgramId=cp.Id;
            insert cpl2;
            
            PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
            acm.PRM_Account_Id__c=newAccount.id;
            acm.PRM_Status_Nm__c='Approved';
            acm.PRM_Channel_Program_Id__c=cp.Id;
            acm.PRM_Channel_Program_Level_Id__c=cpl1.Id;
            acm.PRM_Partner_Role__c='Service Provider';
            insert acm;
            
            PRM_IPA_Membership__c membership11 = new PRM_IPA_Membership__c();
            membership11.PRM_Account_Channel_Membership__c = acm.id;
            membership11.PRM_Partner_Role__c = 'Seller';
            membership11.PRM_Partner_Tier__c=cpl2.Id;
            membership11.PRM_Status__c= 'Approved';
            insert membership11;
            
            PRM_IPA_Membership__c membership = new PRM_IPA_Membership__c();
            membership.PRM_Account_Channel_Membership__c = acm.id;
            membership.PRM_Partner_Role__c = 'Seller';
            membership.PRM_Partner_Tier__c=cpl2.Id;
            membership.PRM_Status__c= 'Pending';
            insert membership;
                        
            
        }catch(Exception ex){
            //System.debug('Ex -->'+ex.getMessage());
        }
        
    }
    
     @isTest static void testIPAMembershipRecords4(){
        try{
            
            Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();        
            Account newAccount = new Account();//Account
            newAccount.RecordTypeId = recordTypeIdAccount;
            newAccount.Name='Greg Thomas';
            newAccount.BillingCity='City';
            newAccount.BillingStreet='Street';
            newAccount.BillingCountry='India';
            newAccount.BillingPostalCode='Postal code';
            newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
            insert newAccount;
            
            ChannelProgram cp = new ChannelProgram(); //Channel Program
            cp.Name='Intel Partner Alliance';
            cp.PRM_programCode__c='IPA';
            insert cp;
            
            ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
            cpl.Name='Titanium';
            cpl.ProgramId=cp.Id;
            insert cpl;
            
            ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
            cpl1.Name='Member';
            cpl1.ProgramId=cp.Id;
            insert cpl1;
            
            ChannelProgramLevel cpl2=new ChannelProgramLevel(); //Channel Program Level
            cpl2.Name='Gold';
            cpl2.ProgramId=cp.Id;
            insert cpl2;
            
            PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
            acm.PRM_Account_Id__c=newAccount.id;
            acm.PRM_Status_Nm__c='Approved';
            acm.PRM_Channel_Program_Id__c=cp.Id;
            acm.PRM_Channel_Program_Level_Id__c=cpl1.Id;
            acm.PRM_Partner_Role__c='Service Provider';
            String key = acm.PRM_Partner_Role__c+acm.PRM_Channel_Program_Level_Id__c;

            insert acm;
            List<PRM_IPA_Membership__c> memlist = new List<PRM_IPA_Membership__c>();
            PRM_IPA_Membership__c membership11 = new PRM_IPA_Membership__c();
            membership11.PRM_Account_Channel_Membership__c = acm.id;
            membership11.PRM_Partner_Role__c = 'Seller';
            membership11.PRM_Partner_Tier__c=cpl2.Id;
            membership11.PRM_Status__c= 'Approved';
            //insert ;
            insert membership11;  
            
            
           
            
            PRM_IPA_Membership__c membership = new PRM_IPA_Membership__c();
            membership.PRM_Account_Channel_Membership__c = acm.id;
            membership.PRM_Partner_Role__c = 'Seller';
            membership.PRM_Partner_Tier__c=cpl2.Id;
            membership.PRM_Status__c= 'Pending';
            memlist.add(membership);
            
             
            PRM_IPA_Membership__c membership2 = new PRM_IPA_Membership__c();
            membership.PRM_Account_Channel_Membership__c = acm.id;
            membership.PRM_Partner_Role__c = 'Seller';
            membership.PRM_Partner_Tier__c=cpl2.Id;
            membership.PRM_Status__c= 'Complete';
            memlist.add(membership2);
            
            PRM_IPA_Membership__c membership1 = new PRM_IPA_Membership__c();
            membership1.PRM_Account_Channel_Membership__c = acm.id;
            membership1.PRM_Partner_Role__c = 'Manufacturer';
            membership1.PRM_Partner_Tier__c=cpl2.Id;
            membership1.PRM_Status__c= 'Pending';
            memlist.add(membership1);
            insert(memlist);
            
            membership11.PRM_Status__c='pending';
            update membership11;
            
         
            
        }catch(Exception ex){
            //System.debug('Ex -->'+ex.getMessage());
        }
         
         }
    @isTest static void testIPAMembershipRecords5(){
        try{
            
            Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();        
            Account newAccount = new Account();//Account
            newAccount.RecordTypeId = recordTypeIdAccount;
            newAccount.Name='Greg Thomas';
            newAccount.BillingCity='City';
            newAccount.BillingStreet='Street';
            newAccount.BillingCountry='India';
            newAccount.BillingPostalCode='Postal code';
            newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
            insert newAccount;
            
            ChannelProgram cp = new ChannelProgram(); //Channel Program
            cp.Name='Intel Partner Alliance';
            cp.PRM_programCode__c='IPA';
            insert cp;
            
           ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
            cpl.Name='Titanium';
            cpl.ProgramId=cp.Id;
            insert cpl;
            
            ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
            cpl1.Name='Member';
            cpl1.ProgramId=cp.Id;
            insert cpl1;
            
            ChannelProgramLevel cpl2=new ChannelProgramLevel(); //Channel Program Level
            cpl2.Name='Gold';
            cpl2.ProgramId=cp.Id;
            insert cpl2;
            
            PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
            acm.PRM_Account_Id__c=newAccount.id;
            acm.PRM_Status_Nm__c='Approved';
            acm.PRM_Channel_Program_Id__c=cp.Id;
            acm.PRM_Channel_Program_Level_Id__c=cpl1.Id;
            acm.PRM_Partner_Role__c='Service Provider';
            
           insert acm;
            
            PRM_AccountChannelMembership__c acm1= new PRM_AccountChannelMembership__c(); //Account Channel Membership
            acm1.PRM_Account_Id__c=newAccount.id;
            acm1.PRM_Status_Nm__c='Approved';
            acm1.PRM_Channel_Program_Id__c=cp.Id;
            acm1.PRM_Channel_Program_Level_Id__c=cpl1.Id;
            acm1.PRM_Partner_Role__c='Service Provider';
            
           insert acm1;
            
            
            
            
            PRM_IPA_Membership__c membership11 = new PRM_IPA_Membership__c();
            membership11.PRM_Account_Channel_Membership__c = acm.id;
            membership11.PRM_Partner_Role__c = 'Seller';
            membership11.PRM_Partner_Tier__c=cpl2.Id;
            membership11.PRM_Status__c= 'Pending';
            insert membership11;
            
            PRM_IPA_Membership__c membership = new PRM_IPA_Membership__c();
            membership.PRM_Account_Channel_Membership__c = acm.id;
            membership.PRM_Partner_Role__c = 'Seller';
            membership.PRM_Partner_Tier__c=cpl1.Id;
            membership.PRM_Status__c= 'Pending';
            insert membership;
            
            
        }catch(Exception ex){
            //System.debug('Ex -->'+ex.getMessage());
        }
        
    }
    
    @isTest static void testIPAMembershipRecords6(){
        try{
            
            Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();        
            Account newAccount = new Account();//Account
            newAccount.RecordTypeId = recordTypeIdAccount;
            newAccount.Name='Tom Cruise';
            newAccount.BillingCity='City';
            newAccount.BillingStreet='Street';
            newAccount.BillingCountry='India';
            newAccount.BillingPostalCode='Postal code';
            newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
            insert newAccount;
            
            ChannelProgram cp = new ChannelProgram(); //Channel Program
            cp.Name='Intel Partner Alliance';
            cp.PRM_programCode__c='IPA';
            insert cp;
            
           ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
            cpl.Name='Titanium';
            cpl.ProgramId=cp.Id;
            insert cpl;
            
            ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
            cpl1.Name='Member';
            cpl1.ProgramId=cp.Id;
            insert cpl1;
            
            ChannelProgramLevel cpl2=new ChannelProgramLevel(); //Channel Program Level
            cpl2.Name='Gold';
            cpl2.ProgramId=cp.Id;
            insert cpl2;
            
            PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
            acm.PRM_Account_Id__c=newAccount.id;
            acm.PRM_Status_Nm__c='Approved';
            acm.PRM_Channel_Program_Id__c=cp.Id;
            acm.PRM_Channel_Program_Level_Id__c=cpl1.Id;
            acm.PRM_Partner_Role__c='Service Provider';
            
           insert acm;
            
            OPID_Sync_Request__c opidsyncreq= new OPID_Sync_Request__c(); //OPID Sync Request
            opidsyncreq.OPID_Account__c=newAccount.id;
            opidsyncreq.Status__c='In Progress';
            
            insert opidsyncreq;
            
            
            PRM_IPA_Membership__c membership = new PRM_IPA_Membership__c();
            membership.PRM_Account_Channel_Membership__c = acm.id;
            membership.PRM_Partner_Role__c = 'Seller';
            membership.PRM_Partner_Tier__c=cpl1.Id;
        
            insert membership;
            
            
        }catch(Exception ex){
            //System.debug('Ex -->'+ex.getMessage());
        }
        
    }
}