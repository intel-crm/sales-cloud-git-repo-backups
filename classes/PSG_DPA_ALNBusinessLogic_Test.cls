/****************************************************************************************************
Apex Class Name : PSG_DPA_ALNBusinessLogic_Test
Version         : 1.0 
Created Date    : 08/13/2021
Function        : Test class for PSG_DPA_ALNBusinessLogic.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Hari                    08/13/2021                Created
*****************************************************************************************************/
@isTest
public class PSG_DPA_ALNBusinessLogic_Test {
    @testSetup
    public static void setUpData(){
        List<User> lstUsers3 = PSG_Test_Utility.createSOSUser();
        if(!lstUsers3.isEmpty()){
            system.runAs(lstUsers3[0]){
                
                Account acc = PSG_Test_Utility.createAccount();
                acc.Core_Direct_Account_Active_Ind__c=true;
                
                Contact con = PSG_Test_Utility.createContact(acc.Id);
                User partnerUser = PSG_Test_Utility.createPartnerUser(acc.Id);
                PSG_Test_Utility.CreatePriceBook('PSG Price Book');
                List<Product2> lstProd = PSG_Test_Utility.CreateProduct(3);
                PSG_Test_Utility.createGroup();

                Test.startTest();
                
                List<SBQQ__Quote__c> lstquote = PSG_Test_Utility.createQuote(acc.Id, partnerUser.ContactId, 2);
                
                Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Direct_Account').getRecordTypeId();
				acc.RecordTypeId = accRecordTypeId;
                acc.Core_Direct_Account_Type_Nm__c ='End Customer Parent';
                acc.Core_Is_Pricing_Parent_ChkBox__c=true;
                acc.Core_Direct_Account_Active_Ind__c=true;
                update acc;    
                Account acc2 = PSG_Test_Utility.createAccount();
                Id accRecordTypeId2 = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
				acc2.RecordTypeId = accRecordTypeId2;
                acc2.Core_Direct_Pricing_Parent_Id__c = acc.Id;
                acc2.Core_PSG_Account__c = true;
                update acc2;
                lstquote[0].core_cpq_sap_ecp_nm__c = acc.Id;
                lstquote[0].core_cpq_end_customer_nm__c =acc2.Id;
                lstquote[0].core_cpq_active_cb__c = false;
                update lstquote[0];
                List<core_cpq_dpa_aln__c> dpa_List = PSG_Test_Utility.createDPARecord(lstquote[0],acc.Id);
                dpa_List[0].core_cpq_parent_aln_txt__c='Test';
                
                update dpa_List;
                List<core_cpq_dpa_aln_line__c> dpaLines_List = PSG_Test_Utility.createDPALines(dpa_List[0].Id,1);
                System.assert(lstquote[0].Id!=null,'Quote creation successfull');
                Test.stopTest();
            }   
        }
    }
    
    @isTest static void testData1(){
        Id recordtypeId=[SELECT Id,name,developername from RecordType where sobjecttype='Account' and Developername='Core_Direct_Account' LIMIT 1].Id;
        List<User> lstUsers = PSG_Test_Utility.createSOSUser();
        List<User> boUsers=PSG_Test_Utility.createBOUser();
        if(!lstUsers.isEmpty()){
            system.runAs(lstUsers[0]){
                System.assert(!lstUsers.isEmpty(),'User creation successfull');
                Account a1=PSG_Test_Utility.createDistyAccount();
                a1.Core_Account_BU_Focus__c='PSG-DISTI';
                update a1;
                PSG_Test_Utility.createDistyTestUser(a1.Id);
                List<SBQQ__Quote__c> lstquote    = [select id, SBQQ__Distributor__c, SBQQ__Distributor__r.Core_Geo__c,core_cpq_disty_group_name__c from SBQQ__Quote__c limit 2];
                List<core_cpq_dpa_aln__c> lstDPA = [select id, core_cpq_active_quote__c, core_cpq_account_program__c,core_cpq_ship_start_date_dt__c,core_cpq_sap_end_customer_nm__c,core_cpq_sap_distributor_nm__c,core_cpq_ship_end_date_dt__c,core_cpq_duration_nbr__c,core_cpq_cm_name_nm__c,OwnerId, 
                                                    core_cpq_cm_country_txt__c,core_cpq_quote_distributor__c,core_cpq_disty_submitted_user__c,core_cpq_disty_group_name__c FROM core_cpq_dpa_aln__c limit 2 ];
                Map<Id,core_cpq_dpa_aln__c> oldMap = new Map<Id,core_cpq_dpa_aln__c>([select id, core_cpq_active_quote__c,core_cpq_quote_distributor__c,core_cpq_account_program__c, core_cpq_ship_start_date_dt__c,core_cpq_sap_end_customer_nm__c,core_cpq_sap_distributor_nm__c,core_cpq_ship_end_date_dt__c,core_cpq_duration_nbr__c,core_cpq_cm_name_nm__c,OwnerId, 
                                                                                      core_cpq_disty_submitted_user__c FROM core_cpq_dpa_aln__c limit 2 ]);
                Test.startTest();
                lstDPA[0].core_cpq_duration_nbr__c = 2;
                lstDPA[0].core_cpq_cm_name_nm__c = null;
                lstDPA[0].core_cpq_assigned_to_nm__c=UserInfo.getUserId();
                lstDPA[0].core_cpq_quote_distributor__c=a1.Id;
                lstDPA[0].core_cpq_active_quote__c=lstquote[0].Id;
                core_cpq_disty_visibility__c distyVisibility=new core_cpq_disty_visibility__c();
                distyVisibility.core_cpq_distributor__c=a1.Id;
                distyVisibility.core_cpq_quote__c=lstquote[0].Id;
                insert distyVisibility;
                core_cpq_disty_visibility__c distyVisibility1=new core_cpq_disty_visibility__c();
                distyVisibility1.core_cpq_distributor__c=a1.Id;
                distyVisibility1.core_cpq_quote__c=lstquote[1].Id;
                insert distyVisibility1;
                if(!lstDPA.isEmpty()){
                    try{
                        update lstDPA;
                    }catch(Exception e){}
                }
                lstDPA[0].core_cpq_cm_name_nm__c = a1.Id;
                if(!lstDPA.isEmpty()){
                    try{
                        update lstDPA;
                    }catch(Exception e){}
                }
                PSG_DPA_ALNBusinessLogic.shareWithDistyUser(lstDPA,new set<Id>{a1.Id},new Map<String,Set<Id>> {lstquote[0].Id => new set<Id>{a1.Id},lstquote[1].Id => new set<Id>{a1.Id}});
                PSG_DPA_ALNBusinessLogic.beforeInsertUpdateOperations(lstDPA,oldMap,true);
                PSG_DPA_ALNBusinessLogic.afterInsertUpdateOperations(lstDPA,oldMap,true);
                Test.stopTest();
            }
        }
    }
}