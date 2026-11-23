/****************************************************************************************************
Apex Class Name : PSG_PRIDBusinessLogic_Test
Version         : 1.0 
Created Date    : 08/13/2021
Function        : Test class for PRIDBusinessLogic.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Vijay                     08/13/2021                Created
*****************************************************************************************************/
@isTest
public class PSG_PRIDBusinessLogic_Test {
    /*@testSetup
    public static void setUpData(){
        SBQQ.TriggerControl.disable();
        List<User> lstUsers3 = PSG_Test_Utility.createBOUser();
        if(!lstUsers3.isEmpty()){ 
            system.runAs(lstUsers3[0]){  
                Account acc1 = PSG_Test_Utility.createAccount();
                acc1.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Direct_Account').getRecordTypeId();
                acc1.Core_Direct_Account_Type_Nm__c='End Customer Parent';
                acc1.Core_Is_Pricing_Parent_ChkBox__c=true;
                acc1.Core_Direct_Account_Active_Ind__c=true;
                update acc1;
                Account acc = PSG_Test_Utility.createAccount();
                acc.Core_Direct_Pricing_Parent_Id__c=acc1.id;
                acc.Core_Direct_Legal_Parent_Id__c=acc1.id;
                update acc;
                
                //Contact con = PSG_Test_Utility.createContact(acc.Id);
                User partnerUser = PSG_Test_Utility.createPartnerUser(acc.Id);
                Test.startTest();
                List<SBQQ__Quote__c> lstquote = PSG_Test_Utility.createQuote(acc.Id, partnerUser.ContactId, 2);
                lstquote[0].core_cpq_end_customer_nm__c=acc.id;
                lstquote[0].core_cpq_sap_ecp_nm__c =acc1.id;
                update lstquote;
                if(lstquote[0] != null){
                    pricebook2 pb = [Select id from pricebook2 limit 1];
                    lstquote[0].core_cpq_price_book_nm__c = pb.Id;
                    Update lstquote[0];
                    List<SBQQ__QuoteLine__c> lstquoteLines= PSG_Test_Utility.createQuoteLines(lstquote[0].Id, 40);
                }
                List<core_cpq_dpa_aln__c> lstdpa = PSG_Test_Utility.createDPARecord(lstquote[0],acc1.Id);
                Test.stopTest();
                lstdpa[0].core_cpq_disty_submitted_user__c=Userinfo.getUserId();
                lstdpa[0].core_cpq_record_type_identifier__c='DPA';
                lstdpa[0].core_cpq_status_txt__c='Approved';
                update lstdpa[0];
                List<core_cpq_dpa_aln__c> lstdpa1 = PSG_Test_Utility.createDPARecord(lstquote[0],acc1.Id);
                lstdpa1[0].core_cpq_disty_submitted_user__c=Userinfo.getUserId();
                lstdpa1[0].core_cpq_record_type_identifier__c='ALN';
                lstdpa1[0].core_cpq_status_txt__c='Approved';
                update lstdpa[0];
                System.assertEquals('Approved',lstdpa1[0].core_cpq_status_txt__c );
            }   
        }
    }
    
    @isTest
    private static void updationDPATest(){
        SBQQ.TriggerControl.disable();
        SBQQ__Quote__c q=[Select Id,Name from SBQQ__Quote__c LIMIT 1];
        Test.startTest();
        PRIDBusinessLogic.updateUnderlyingDPAALN(new set<Id>{q.Id},False);
        Test.stopTest();
        System.assert(q!=null,'Successfully retrieved');
    }
    
    @isTest
    private static void extensionDPATest(){
        SBQQ.TriggerControl.disable();
        SBQQ__Quote__c q=[Select Id,Name from SBQQ__Quote__c LIMIT 1];
        List<Account> acc = [select id from Account limit 1];
        PRIDBusinessLogic.extendUnderlyingDPAALN(new set<Id>{q.Id},new Map<Id,Date>{q.Id => System.today()+10});
        List<Product2> p=PSG_Test_Utility.createProduct(1);
        Price_Prid__c prid=new Price_Prid__c();
        prid.core_cpq_type__c='AVP';
        prid.core_cpq_active_pricing_cb__c=TRUE;
        prid.core_cpq_active_cb__c=TRUE;
        prid.core_cpq_device__c = p[0].Id;
        prid.core_cpq_sap_ecp_nm__c = acc[0].Id;
        prid.core_cpq_lower_bound_qty_nbr__c=10;
        prid.core_cpq_upper_bound_qty_nbr__c=20;
        insert prid;
        System.assert(prid!=null,'Successfully inserted');
        
        Test.startTest();
        Price_Prid__c prid1=new Price_Prid__c();
        prid1.core_cpq_type__c='AVP';
        prid1.core_cpq_active_pricing_cb__c=TRUE;
        prid1.core_cpq_active_cb__c=FALSE;
        prid1.core_cpq_device__c = p[0].Id;
        prid1.core_cpq_sap_ecp_nm__c = acc[0].Id;
        prid1.core_cpq_lower_bound_qty_nbr__c=10;
        prid1.core_cpq_upper_bound_qty_nbr__c=20;
        insert prid1;
        prid1.core_cpq_active_cb__c=TRUE;
        try{
            update prid1;
        }catch(Exception e){}
        Test.stopTest();
        
    }
    @isTest
    public static void PRIDBusinessLogic1(){
        SBQQ.TriggerControl.disable();
        try{         
            Test.StartTest();
            List<User> lstUsers2 = PSG_Test_Utility.createAdminUser();
            List<SBQQ__QuoteLine__c> lstquoteLines = [select id ,core_cpq_PRID__c,price_suggested_resale_amt__c,price_brokencost_amt__c ,SBQQ__Quote__r.SBQQ__Status__c,core_cpq_distributor_margin_pct__c from SBQQ__QuoteLine__c limit 2];
            List<SBQQ__Quote__c> lstquote = [select id from SBQQ__Quote__c limit 1];
            List<Account> acc = [select id from Account limit 1];
            List<Product2> product = PSG_Test_Utility.createProduct(1);
            List<price_prid__c> prId = new List<price_prid__c>();
            List<price_prid__c> prIdList = new List<price_prid__c>();
            List<price_prid__c> prIdList2 = new List<price_prid__c>();
            price_prid__c prIdRec = new price_prid__c();
            prIdRec.core_cpq_active_cb__c = true;
            prIdRec.core_cpq_device__c = product[0].Id;
            prIdRec.core_cpq_sap_ecp_nm__c = acc[0].Id;
            prIdRec.core_cpq_lower_bound_qty_nbr__c =  1;
            prIdRec.core_cpq_upper_bound_qty_nbr__c = 100;
            prIdRec.core_cpq_type__c =Label.PSG_PRID_Type_AVP;
            prIdRec.core_cpq_quote__c = lstquote[0].Id;
            prIdRec.core_cpq_quoteline__c = lstquoteLines[0].Id;
            prIdRec.price_amt__c = 200;
            prIdRec.core_cpq_quantity_eau_nbr__c = 100;
            prIdRec.core_cpq_price_start_date_dt__c =  Date.newInstance(2010, 12, 9);
            prIdRec.core_cpq_price_end_date_dt__c =  Date.newInstance(2011, 12, 9);
            prIdRec.core_cpq_prid_eligiblity_date_dt__c =  Date.newInstance(2012, 12, 9);
            prIdRec.core_cpq_update_underlying_quotelines_cb__c =true;
            prIdRec.core_cpq_active_cb__c =false;
            prIdRec.core_cpq_active_pricing_cb__c = false;
            prIdRec.core_cpq_comments_txt__c='';
            price_prid__c prIdRec2 = new price_prid__c();
            prIdRec2.core_cpq_active_cb__c = true;
            prIdRec2.core_cpq_device__c = product[0].Id;
            prIdRec2.core_cpq_sap_ecp_nm__c = acc[0].Id;
            prIdRec2.core_cpq_lower_bound_qty_nbr__c =  1;
            prIdRec2.core_cpq_upper_bound_qty_nbr__c = 100;
            prIdRec2.core_cpq_type__c ='Flat';
            prIdRec2.core_cpq_quote__c = lstquote[0].Id;
            prIdRec2.core_cpq_quoteline__c = lstquoteLines[0].Id;
            prIdRec2.price_amt__c = 200;
            prIdRec2.core_cpq_quantity_eau_nbr__c = 200;
            prIdRec2.core_cpq_update_underlying_quotelines_cb__c =true;
            prIdRec2.core_cpq_active_pricing_cb__c = true;
            prIdRec2.core_cpq_comments_txt__c='';
            price_prid__c prIdRec23 = new price_prid__c();
            prIdRec23.core_cpq_active_cb__c = false;
            prIdRec23.core_cpq_device__c = product[0].Id;
            prIdRec23.core_cpq_sap_ecp_nm__c = acc[0].Id;
            prIdRec23.core_cpq_lower_bound_qty_nbr__c =  1;
            prIdRec23.core_cpq_upper_bound_qty_nbr__c = 100;
            prIdRec23.core_cpq_type__c ='Flat';
            prIdRec23.core_cpq_quote__c = lstquote[0].Id;
            prIdRec23.core_cpq_quoteline__c = lstquoteLines[0].Id;
            prIdRec23.price_amt__c = 200;
            prIdRec23.core_cpq_quantity_eau_nbr__c = 200;
            prIdRec23.core_cpq_update_underlying_quotelines_cb__c =true;
            prIdRec23.core_cpq_active_pricing_cb__c = false;
            prIdRec23.core_cpq_comments_txt__c='';
            prId.add(prIdRec);
            prId.add(prIdRec2);
            prId.add(prIdRec23); 
            Integer j=0;    
            for(Integer i=0;i<10;i++);{
                price_prid__c prIdRec32 = new price_prid__c();
                prIdRec32.core_cpq_active_cb__c = false;
                prIdRec32.core_cpq_device__c = product[0].Id;
                prIdRec32.core_cpq_sap_ecp_nm__c = acc[0].Id;
                prIdRec32.core_cpq_lower_bound_qty_nbr__c =  1+j;
                prIdRec32.core_cpq_upper_bound_qty_nbr__c = 100+j;
                prIdRec32.core_cpq_type__c ='AVP';
                prIdRec32.core_cpq_quote__c = lstquote[0].Id;
                prIdRec32.core_cpq_quoteline__c = lstquoteLines[0].Id;
                prIdRec32.price_amt__c = 201;
                prIdRec32.core_cpq_quantity_eau_nbr__c = 200+j;
                prIdRec32.core_cpq_update_underlying_quotelines_cb__c =false;
                prIdRec32.core_cpq_comments_txt__c='';
                j++;
                prIdList2.add(prIdRec32);
            }
            prId.addAll(prIdList2);
            insert prId;
            
            prId[2].core_cpq_active_cb__c = false;
            System.assert(prId!=null,'Successfully inserted');
            lstquoteLines[0].core_cpq_PRID__c=prId[0].Id;
            lstquoteLines[0].core_cpq_quote_line_type_txt__c='AVP';
            lstquoteLines[0].price_suggested_resale_amt__c=76;
            lstquoteLines[0].SBQQ__Quantity__c=200;
            lstquoteLines[0].core_cpq_lower_bound_qty_qty__c=1;
            lstquoteLines[0].core_cpq_upper_bound_qty_nbr__c=200;
            lstquoteLines[0].core_cpq_price_eligibility_date_dt__c= Date.newInstance(2016, 12, 9);
            lstquoteLines[0].core_cpq_active_Pricing__c=true;
            lstquoteLines[0].core_cpq_pricing_start_date_dt__c=Date.newInstance(2017, 12, 10);
            update lstquoteLines;
            System.assert(lstquoteLines!=null,'Successfully updated');
            
            
            Map<Id, price_prid__c> prIdMap = new Map<Id, price_prid__c>([select id, core_cpq_active_cb__c,core_cpq_quantity_eau_nbr__c,core_cpq_device__c,core_cpq_lower_bound_qty_nbr__c,core_cpq_upper_bound_qty_nbr__c , core_cpq_type__c ,core_cpq_quote__c,core_cpq_quoteline__c,price_amt__c,core_cpq_price_start_date_dt__c,core_cpq_price_end_date_dt__c,core_cpq_update_underlying_quotelines_cb__c,core_cpq_prid_eligiblity_date_dt__c,core_cpq_prid_review_date_dt__c,core_cpq_prid_reviewer__c,core_cpq_active_pricing_cb__c from price_prid__c]);
            prIdMap.get(prId[1].Id).core_cpq_active_cb__c = false;
            prIdMap.get(prId[2].Id).core_cpq_active_pricing_cb__c = true;
            Map<Id, price_prid__c> oldprIdMap = new Map<Id, price_prid__c>([select id, core_cpq_active_cb__c,core_cpq_quantity_eau_nbr__c,core_cpq_device__c,core_cpq_lower_bound_qty_nbr__c,core_cpq_upper_bound_qty_nbr__c , core_cpq_type__c ,core_cpq_quote__c,core_cpq_quoteline__c,price_amt__c,core_cpq_price_start_date_dt__c,core_cpq_price_end_date_dt__c,core_cpq_update_underlying_quotelines_cb__c,core_cpq_prid_eligiblity_date_dt__c,core_cpq_prid_review_date_dt__c,core_cpq_prid_reviewer__c,core_cpq_active_pricing_cb__c from price_prid__c ]);
            oldprIdMap.get(prId[0].Id).core_cpq_update_underlying_quotelines_cb__c = false;
            oldprIdMap.get(prId[0].Id).core_cpq_active_cb__c = true;
            oldprIdMap.get(prId[0].Id).price_amt__c = 501;
            oldprIdMap.get(prId[0].Id).core_cpq_quantity_eau_nbr__c = 70;
            oldprIdMap.get(prId[0].Id).core_cpq_active_pricing_cb__c = true;
            Integer k=1;
            for(price_prid__c pridrecord :prIdList2){
                oldprIdMap.get(pridrec2.Id).core_cpq_active_cb__c = true;
            }
            prIdList2.addall(prId);
            Set<Id> quoteLinesToIgnoreUpdateSet = new Set<Id>();
            Set<Id> quoteLinesToIgnoreUpdateSet2 = new Set<Id>();
            price_prid__c prIdRec3 = new price_prid__c();
            prIdRec3.core_cpq_active_cb__c = true;
            prIdRec3.core_cpq_device__c = product[0].Id;
            prIdRec3.core_cpq_sap_ecp_nm__c = acc[0].Id;
            prIdRec3.core_cpq_lower_bound_qty_nbr__c =  1;
            prIdRec3.core_cpq_upper_bound_qty_nbr__c = 100;
            prIdRec3.core_cpq_type__c ='Flat';
            prIdRec3.core_cpq_quote__c = lstquote[0].Id;
            prIdRec3.core_cpq_quoteline__c = lstquoteLines[0].Id;
            prIdRec3.price_amt__c = 201;
            prIdRec3.core_cpq_quantity_eau_nbr__c = 200;
            prIdRec3.core_cpq_update_underlying_quotelines_cb__c =true;
            prIdList.add(prIdRec3);
            Map<Id, price_prid__c> newPRIDMap = new Map<Id, price_prid__c>([select id, core_cpq_active_cb__c,core_cpq_quantity_eau_nbr__c,core_cpq_device__c,core_cpq_lower_bound_qty_nbr__c,core_cpq_upper_bound_qty_nbr__c , core_cpq_type__c ,core_cpq_quote__c,core_cpq_quoteline__c,price_amt__c,core_cpq_price_start_date_dt__c,core_cpq_price_end_date_dt__c,core_cpq_update_underlying_quotelines_cb__c,core_cpq_prid_eligiblity_date_dt__c,core_cpq_prid_review_date_dt__c,core_cpq_prid_reviewer__c from price_prid__c where Id=: prIdRec3.Id ]);
            j=0;    
            for(Integer i=0;i<10;i++);{ 
                price_prid__c prIdRec32 = new price_prid__c();
                prIdRec32.core_cpq_active_cb__c = true;
                prIdRec32.core_cpq_device__c = product[0].Id;
                prIdRec32.core_cpq_sap_ecp_nm__c = acc[0].Id;
                prIdRec32.core_cpq_lower_bound_qty_nbr__c =  1+j;
                prIdRec32.core_cpq_upper_bound_qty_nbr__c = 100+j;
                prIdRec32.core_cpq_type__c ='AVP';
                prIdRec32.core_cpq_quote__c = lstquote[0].Id;
                prIdRec32.core_cpq_quoteline__c = lstquoteLines[0].Id;
                prIdRec32.price_amt__c = 201;
                prIdRec32.core_cpq_quantity_eau_nbr__c = 200+j;
                prIdRec32.core_cpq_update_underlying_quotelines_cb__c =true;
                j++;
                prIdList.add(prIdRec32);
            }
            
            if(!prIdList.isEmpty()){
                insert prIdList;
            }
            Set<Id> pridNewSet = new Set<Id>();
            for(price_prid__c prIdRec32:prIdList){
                pridNewSet.add(prIdRec32.Id);
            }
            Test.StopTest();
            Map<Id, price_prid__c> newPRIDMap2 = new Map<Id, price_prid__c>([select id, core_cpq_active_cb__c,core_cpq_quantity_eau_nbr__c,core_cpq_device__c,core_cpq_lower_bound_qty_nbr__c,core_cpq_upper_bound_qty_nbr__c , core_cpq_type__c ,core_cpq_quote__c,core_cpq_quoteline__c,price_amt__c,core_cpq_price_start_date_dt__c,core_cpq_price_end_date_dt__c,core_cpq_update_underlying_quotelines_cb__c,core_cpq_prid_eligiblity_date_dt__c,core_cpq_prid_review_date_dt__c,core_cpq_prid_reviewer__c from price_prid__c where Id IN :pridNewSet ]);
            List<SBQQ__QuoteLine__c> underlyingQuoteLineList = new List<SBQQ__QuoteLine__c>();
            for(SBQQ__QuoteLine__c quoteLineRec :[SELECT Id,core_cpq_dollar_change_flag_cb__c,core_cpq_lower_bound_qty_qty__c,price_suggested_resale_amt__c,core_cpq_quote_line_type_txt__c,core_cpq_price_eligibility_date_dt__c,core_cpq_comments_txt__c,
                                                  core_cpq_PRID__r.price_amt__c,core_cpq_PRID__r.core_cpq_lower_bound_qty_nbr__c,SBQQ__Quantity__c,core_cpq_pricing_start_date_dt__c,core_cpq_pricing_end_date_dt__c,
                                                  core_cpq_PRID__r.core_cpq_upper_bound_qty_nbr__c,core_cpq_PRID__r.core_cpq_quantity_eau_nbr__c,core_cpq_PRID__r.core_cpq_quoteline__c,core_cpq_upper_bound_qty_nbr__c,
                                                  core_cpq_PRID__r.core_cpq_price_start_date_dt__c,core_cpq_PRID__r.core_cpq_active_cb__c,core_cpq_review_date_dt__c,core_cpq_reviewer__c,core_cpq_active_Pricing__c,
                                                  core_cpq_PRID__r.core_cpq_price_end_date_dt__c,core_cpq_PRID__r.core_cpq_prid_eligiblity_date_dt__c,core_cpq_PRID__r.core_cpq_active_pricing_cb__c,core_cpq_PRID__r.core_cpq_comments_txt__c,
                                                  core_cpq_PRID__r.core_cpq_prid_reviewer__c,core_cpq_PRID__r.core_cpq_prid_review_date_dt__c
                                                  FROM SBQQ__QuoteLine__c ]){
                                                      quoteLineRec.price_suggested_resale_amt__c=76;
                                                      quoteLineRec.SBQQ__Quantity__c=200;
                                                      quoteLineRec.core_cpq_lower_bound_qty_qty__c=1;
                                                      quoteLineRec.core_cpq_upper_bound_qty_nbr__c=200;
                                                      quoteLineRec.core_cpq_price_eligibility_date_dt__c= Date.newInstance(2016, 12, 9);
                                                      quoteLineRec.core_cpq_active_Pricing__c=true;
                                                      quoteLineRec.core_cpq_pricing_start_date_dt__c=Date.newInstance(2017, 12, 10);
                                                      underlyingQuoteLineList.add(quoteLineRec);
                                                  }
            Map<String,String> quoteLineApiToPridApiMap = new Map<String,String>{
                'price_suggested_resale_amt__c' => 'price_amt__c',
                    'SBQQ__Quantity__c' => 'core_cpq_quantity_eau_nbr__c',
                    'core_cpq_upper_bound_qty_nbr__c' => 'core_cpq_upper_bound_qty_nbr__c',
                    'core_cpq_lower_bound_qty_qty__c' => 'core_cpq_lower_bound_qty_nbr__c',
                    'core_cpq_pricing_start_date_dt__c' => 'core_cpq_price_start_date_dt__c',
                    'core_cpq_pricing_end_date_dt__c' => 'core_cpq_price_end_date_dt__c',
                    'core_cpq_price_eligibility_date_dt__c' => 'core_cpq_prid_eligiblity_date_dt__c',
                    'core_cpq_review_date_dt__c' => 'core_cpq_prid_review_date_dt__c',
                    'core_cpq_reviewer__c' => 'core_cpq_prid_reviewer__c',
                    'core_cpq_active_Pricing__c' => 'core_cpq_active_pricing_cb__c',
                    'core_cpq_comments_txt__c' => 'core_cpq_comments_txt__c'
                    };
            Map<String,String> pridApiToQuoteLineApiMap = new Map<String,String>{
                'price_amt__c' => 'price_suggested_resale_amt__c',
                    'core_cpq_quantity_eau_nbr__c' => 'SBQQ__Quantity__c',
                    'core_cpq_upper_bound_qty_nbr__c' => 'core_cpq_upper_bound_qty_nbr__c',
                    'core_cpq_lower_bound_qty_nbr__c' => 'core_cpq_lower_bound_qty_qty__c',
                    'core_cpq_price_start_date_dt__c' => 'core_cpq_pricing_start_date_dt__c',
                    'core_cpq_price_end_date_dt__c' => 'core_cpq_pricing_end_date_dt__c',
                    'core_cpq_prid_eligiblity_date_dt__c' => 'core_cpq_price_eligibility_date_dt__c',
                    'core_cpq_prid_review_date_dt__c' => 'core_cpq_review_date_dt__c',
                    'core_cpq_prid_reviewer__c' => 'core_cpq_reviewer__c',
                    'core_cpq_active_pricing_cb__c' => 'core_cpq_active_Pricing__c',
                    'core_cpq_comments_txt__c' => 'core_cpq_comments_txt__c'
                    };
                        
            quoteLinesToIgnoreUpdateSet.add(lstquoteLines[0].Id);
            /*PRIDBusinessLogic.beforeInsertUpdateOperations(prId,prIdMap,false);
            PRIDBusinessLogic.beforeInsertUpdateOperations(prId,prIdMap,true);
            PRIDBusinessLogic.afterInsertUpdateOperations(prId,prIdMap,false,prIdMap);            
            PRIDBusinessLogic.afterInsertUpdateOperations(prIdList2,oldprIdMap,false,newPRIDMap2);*/
            /*PRIDBusinessLogic.updateUnderlyingQL(quoteLineApiToPridApiMap,quoteLinesToIgnoreUpdateSet2,underlyingQuoteLineList,false,true,pridApiToQuoteLineApiMap);
            
            PRIDBusinessLogic.updateUnderlyingQL(quoteLineApiToPridApiMap,quoteLinesToIgnoreUpdateSet2,underlyingQuoteLineList,false,false,pridApiToQuoteLineApiMap);
            PRIDBusinessLogic.pridPosLogic();
        }catch(Exception e){}
    }*/
}