public class PRM_BulkTest_OPID {
    public void testData(){
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id selectBenefitId=Schema.SObjectType.PRM_Specialty__c.getRecordTypeInfosByName().get('Select Benefits').getRecordTypeId();
        
        List<Account> listOfAccount = new List<Account>();
        for(Integer i=0; i<200; i++){
            Account accIntel = PRM_TestUtility.getAccount();
            accIntel.RecordTypeId = accountRecordTypeIntel;
            accIntel.AccountNumber = String.valueOf(Math.random().intValue());
            accIntel.Name='Bulk_Test_Account_'+i;
            accIntel.BillingCity='New Delhi';
            accIntel.BillingCountryCode='IND';
            accIntel.BillingStreet='Joshi Marg';
            accIntel.BillingPostalCode=String.valueOf(Math.random().intValue());
            accIntel.BillingStateCode='KA';
            accIntel.Core_CIM_ID__c=String.valueOf(Math.random().intValue());
            accIntel.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
            accIntel.Core_IPA_Partner_Segment__c = 'Data Center';    
            accIntel.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
            listOfAccount.add(accIntel);
            i=i+1;
        }
        
        insert listOfAccount;
        
        ChannelProgram cprogram = [Select Id from ChannelProgram where Name = 'Intel Partner Alliance' and PRM_programCode__c = 'IPA' and IsActive = true limit 1];
        
        List<ChannelProgramLevel> cpLevelList = [Select id from ChannelProgramLevel where Name IN ('Member','Gold') and ProgramId = :cprogram.Id];  
        
        List<PRM_AccountChannelMembership__c> listOfACM = new List<PRM_AccountChannelMembership__c>();
        for(Integer i=0;i<200;i++){
            PRM_AccountChannelMembership__c  acm = PRM_TestUtility.getMembership();
            acm.PRM_Account_Id__c = listOfAccount[i].Id;
            acm.PRM_Channel_Program_Id__c = cprogram.Id;
            acm.PRM_Partner_Role__c='Distributor';
            acm.PRM_Status_Nm__c ='Approved';
            acm.PRM_Channel_Program_Level_Id__c = cpLevelList[0].id;
            listOfACM.add(acm);
            
            PRM_AccountChannelMembership__c  acm1 = PRM_TestUtility.getMembership();
            acm1.PRM_Account_Id__c = listOfAccount[i].Id;
            acm1.PRM_Channel_Program_Id__c = cprogram.Id;
            acm1.PRM_Partner_Role__c='Distributor';
            acm1.PRM_Status_Nm__c ='Approved';
            acm1.PRM_Channel_Program_Level_Id__c = cpLevelList[1].id;   
            listOfACM.add(acm1);
            
            i=i+1;
        }
        
        insert listOfACM;   
        
        List<PRM_Specialty__c> specList = [Select id from PRM_Specialty__c where name IN ('Video Specialty', 'iCafe')];
        
        List<PRM_Account_Specialty_Association__c> asaList = new List<PRM_Account_Specialty_Association__c>();
        for(Integer i=0;i<200;i++){
            PRM_Account_Specialty_Association__c asa = new PRM_Account_Specialty_Association__c();
            asa.PRM_Account_Id__c= listOfAccount[i].Id;
            asa.PRM_Specialty_Id__c= specList[0].id;
            asa.PRM_Partner_Role__c=System.label.PRM_Service_Provider;       
            asaList.add(asa);
            
            PRM_Account_Specialty_Association__c asa1 = new PRM_Account_Specialty_Association__c();
            asa1.PRM_Account_Id__c= listOfAccount[i].id;
            asa1.PRM_Specialty_Id__c= specList[1].id;
            asa1.PRM_Partner_Role__c='Manufacturer';       
            asaList.add(asa1);
        }
        
        insert asaList;
        
        
        //Benefit
        PRM_PartnerBenefit__c benefit = [Select Id from PRM_PartnerBenefit__c where PRM_Benefit_Cd__c = 'BNFTCS4S' and PRM_Benefit_Type_Nm__c='MKTG' and PRM_Account_Type_Nm__c = 'Mastered_Account' limit 1];
                
        List<PRM_AccountBenefitAssociation__c> abaList = new List<PRM_AccountBenefitAssociation__c>();      
        for(Integer i=0;i<200;i++){
            PRM_AccountBenefitAssociation__c abaObject = new PRM_AccountBenefitAssociation__c();
            abaObject.PRM_Account_Id__c = listOfAccount[i].Id;
            abaObject.PRM_Partner_Benefit_Id__c = benefit.id;
            abaObject.PRM_Status_Nm__c ='Active';        
            abaList.add(abaObject);
            i = i + 1;
        }
        
        insert abaList;
        
        List<Core_OnePartner_Inbound_Message__c> listOfInbound = new List<Core_OnePartner_Inbound_Message__c>();
        for(Integer i=0;i<200;i++){
            Core_OnePartner_Inbound_Message__c inboundTable = new Core_OnePartner_Inbound_Message__c();
            inboundTable.Core_Status__c = 'NEW';
            inboundTable.Core_SalesCloud_AccountID__c = listOfAccount[i].Id;
            inboundTable.Core_OnePartnerID__c = 2222 + i;
            inboundTable.Core_CIM_ID__c=Integer.valueOf(listOfAccount[i].Core_CIM_ID__c);
            inboundTable.Core_OnePartner_Account_Name__c = 'OPID '+ inboundTable.Core_OnePartnerID__c;
            listOfInbound.add(inboundTable);
        }
        
        insert listOfInbound;
        
    }
}