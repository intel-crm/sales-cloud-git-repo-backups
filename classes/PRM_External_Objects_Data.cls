public without sharing class  PRM_External_Objects_Data{
    
    @testVisible public  static  List<k_v_f_training_detail_sfdcs__x> trainingMocked = new List<k_v_f_training_detail_sfdcs__x>();
    @testVisible public static List<k_v_f_detail_value_exchange_sfdcs__x> salesMocked  = new List<k_v_f_detail_value_exchange_sfdcs__x>();
    @testVisible public static List<User> userMock = new List<User>();
    public static Integer PRM_DashboardDownloadLimit = Integer.valueOf(Label.PRM_DashboardDownloadLimit);
    public static string MeasurementPeriod;
    //to get the dynamic URL  --
    @AuraEnabled
    public static String getPageURL(){
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        String url = Label.PRM_Training_Credits_Link;
        return baseUrl+url;
    }
    @AuraEnabled
    public static string pageUrlSales(){
        try {
            String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
            String url = Label.PRM_Sales_Data_Link;
            return baseUrl+url;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    //get the Logged in Users Accout which are associated to him
    //will return Account list if contact is part of OPID
    //otherwise will return Account Id he is part of
    private static Set<Id> currentUserAccounts(){
        Set<Id> accountIds = new Set<Id>();
        String sanitizedSearchKey = String.escapeSingleQuotes(UserInfo.getUserId()); 
        User user = [select Id, username,Core_IPA_One_Partner_Id__c,Core_IPS_AccountId__c from User where Id = :sanitizedSearchKey];//where Id =: currentUserId
        if(user.Core_IPA_One_Partner_Id__c != null){
            accountIds.add(user.Core_IPA_One_Partner_Id__c);         
        }else{
            if(user.Core_IPS_AccountId__c !=null){
                accountIds.add(user.Core_IPS_AccountId__c);
            }
        }
        return accountIds;
    }
    
    // Get the username for logged in user
    // We are using this method in Contact_training_detail LWC Component --
    @AuraEnabled
    public static Integer getContactCredits(){
        String username = getContactId();
        Integer sum =0;
        
        for( k_v_f_training_detail_sfdcs__x lstKvfTd : [select end_dt__c, start_dt__c, value_exchange_period_txt__c, training_credit_qty__c,business_person_id__r.Name
                                                        from  k_v_f_training_detail_sfdcs__x where business_person_id__c =: username order by training_id__c]){
                                                            
                                                        if(Date.valueOf(lstKvfTd.start_dt__c).month()>=Integer.valueOf(Label.PRM_Vx_Frommonth_for_Report) && Date.valueOf(lstKvfTd.end_dt__c).month()<=Integer.valueOf(Label.PRM_Vx_Tomonth_for_Report) && (Date.valueOf(lstKvfTd.start_dt__c).year()==system.today().year()-2 && Date.valueOf(lstKvfTd.end_dt__c).year()==(system.today().year()-1)) || (Date.valueOf(lstKvfTd.start_dt__c).year()==system.today().year()-1 && Date.valueOf(lstKvfTd.end_dt__c).year()==(system.today().year()))){
                                                            sum+=(Integer)lstKvfTd.training_credit_qty__c;
                                                        }
                                                      }
        
        if(Test.isRunningTest()){
            for( k_v_f_training_detail_sfdcs__x lstKvfTd : trainingMocked){
                sum +=(Integer)lstKvfTd.training_credit_qty__c;
            }
        }
        
        return sum;
    }

    @AuraEnabled
    public static Integer getContactTrainingCredits(string trainingperiod){
        String username = getContactId();
        Integer totalCredits =0;
        try{
            for( k_v_f_training_detail_sfdcs__x lstKvfTd : [select end_dt__c, start_dt__c, value_exchange_period_txt__c, training_credit_qty__c,business_person_id__r.Name
                                                        from  k_v_f_training_detail_sfdcs__x where business_person_id__c =: username AND value_exchange_period_txt__c=: trainingperiod order by training_id__c]){
                                                        totalCredits+=(Integer)lstKvfTd.training_credit_qty__c;                                           
        }

        
            if(Test.isRunningTest()){
                for( k_v_f_training_detail_sfdcs__x lstKvfTd : trainingMocked){
                    totalCredits +=(Integer)lstKvfTd.training_credit_qty__c;
                }
            }
        }
        catch(Exception e){
            System.debug('An Exception occurred'+e);
            System.debug('An Exception occurred'+e.getMessage());
            totalCredits=0;
        } 
        
        return totalCredits;
    }
    
    
   //old changes :

 //Wrapper class to return Wrapper list to LWC component --
 public static List<PRM_WrapperForTrainingDetails> getWrapperData(List<k_v_f_training_detail_sfdcs__x> kvfTraining,String startDate, String endDate ){
        
    List<PRM_WrapperForTrainingDetails> wrapper = new List<PRM_WrapperForTrainingDetails>();
    List<k_v_f_training_detail_sfdcs__x> lstOfTrainingDetails = new List<k_v_f_training_detail_sfdcs__x>();
    if(kvfTraining != null && kvfTraining.size() > 0){
        if(String.isEmpty(startDate) || startDate == null || String.isEmpty(endDate) || endDate == null){
            for(k_v_f_training_detail_sfdcs__x trainingDetails : kvfTraining){
                lstOfTrainingDetails.add(trainingDetails);
            }
        }else{
            for(k_v_f_training_detail_sfdcs__x trainingDetails : kvfTraining){
                if( trainingDetails.training_complete_dt__c <= endDate && trainingDetails.training_complete_dt__c >= startDate){
                    lstOfTrainingDetails.add(trainingDetails);
                }
            }
        }
    }else{
    }
    
    PRM_WrapperForTrainingDetails wrpr;
    for( k_v_f_training_detail_sfdcs__x td : lstOfTrainingDetails){
        wrpr = new PRM_WrapperForTrainingDetails();
         if(td.value_exchange_period_txt__c==Label.PRM_Previous_Measurement_Period){
            MeasurementPeriod=system.Label.PRM_Dash_MeasurementPeriod_Prev; 
        }   
        else if(td.value_exchange_period_txt__c==Label.PRM_Current_measurement_period){
            MeasurementPeriod=system.Label.PRM_Dash_MeasurementPeriod_Current; 
        }
        wrpr.account_number = td.business_organization_party_id__r.AccountNumber;//account_number
        wrpr.contact_name = td.business_person_id__r.Name;//contact_name
        wrpr.training_id = td.training_id__c;//training_id
        wrpr.training_name = td.training_nm__c;//training_name
        wrpr.training_credits =(Decimal) td.training_credit_qty__c;//training_credits
        wrpr.training_completion_date = td.training_complete_dt__c;//training_completion_date
        wrpr.Measurement_Period=MeasurementPeriod;
        wrapper.add(wrpr);
    }
    return wrapper;
}


// this will return all the data for the OPID members  
// this method is used in member-training-details LWC component --
@auraEnabled(Cacheable = true)
public static List<PRM_WrapperForTrainingDetails> getExternalOPIDTrainingDetails(){//
    Set<Id> accountIds = currentUserAccounts();
    
    List<k_v_f_training_detail_sfdcs__x> kvfTraining = new List<k_v_f_training_detail_sfdcs__x>();
    for(k_v_f_training_detail_sfdcs__x kvft : [select business_person_id__r.Name,training_id__c,training_complete_dt__c, training_nm__c, business_organization_party_id__r.AccountNumber,training_credit_qty__c,value_exchange_period_txt__c
                                               from  k_v_f_training_detail_sfdcs__x where (business_organization_party_id__c in : accountIds or one_partner_customer_aggregation_id__c in :accountIds) order by training_complete_dt__c desc NULLS LAST]){
                                                   kvfTraining.add(kvft);
                                               }
    if(Test.isRunningTest()){
        kvfTraining = trainingMocked;
    }
    System.debug('from OPID :'+kvfTraining);
    List<PRM_WrapperForTrainingDetails> wrapper = getWrapperData(kvfTraining, '', '');
    return wrapper;
}

    public class opidTrainingParentWrapper{
        @AuraEnabled
        public Boolean limitBreachedopidTraining;
        @AuraEnabled
        public List<PRM_WrapperForTrainingDetails> wrapopidTraining;
    }
    
    

    @auraEnabled(Cacheable = true)
    public static List<PRM_WrapperForTrainingDetails> getExternalTrainingDetails(Integer pagenumber, Integer numberOfRecords, Integer pageSize, String startDate, String endDate){//
        String username = getContactId();
        //-------variables for training details starts here ------------isem
        List<PRM_WrapperForTrainingDetails> wrapper = new List<PRM_WrapperForTrainingDetails>();
        List<k_v_f_training_detail_sfdcs__x> lstOfTrainingDetails = new List<k_v_f_training_detail_sfdcs__x>();
        Map<String,String> mpContactName =  new Map<String, String>();
        ///-------variables for training details end here ------
        set<id> actId = currentUserAccounts();
        List<k_v_f_training_detail_sfdcs__x> lstTrainingDetails = new List<k_v_f_training_detail_sfdcs__x>();
        
        List<k_v_f_training_detail_sfdcs__x> kvfTraining = new List<k_v_f_training_detail_sfdcs__x>();
        for( k_v_f_training_detail_sfdcs__x kvft : [select business_person_id__r.Name,training_id__c,training_complete_dt__c, training_nm__c, business_organization_party_id__r.AccountNumber,training_credit_qty__c,value_exchange_period_txt__c
                                                    from  k_v_f_training_detail_sfdcs__x where business_person_id__c = :username order by training_id__c limit : pageSize offset: (pageSize *( pagenumber -1 ))]){
                                                        kvfTraining.add(kvft);
                                                    }
        if(Test.isRunningTest()){
            kvfTraining = trainingMocked;
        }
        if(kvfTraining != null && kvfTraining.size() > 0){
            if(String.isEmpty(startDate) || startDate == null || String.isEmpty(endDate) || endDate == null){
                for(k_v_f_training_detail_sfdcs__x trainingDetails : kvfTraining){
                    lstOfTrainingDetails.add(trainingDetails);
                }
            }else{
                for(k_v_f_training_detail_sfdcs__x trainingDetails : kvfTraining){
                    if( trainingDetails.training_complete_dt__c <= endDate && trainingDetails.training_complete_dt__c >= startDate){
                        lstOfTrainingDetails.add(trainingDetails);
                    }
                }
            }
        }else{
            System.debug('List is Empty...');
        }
        
        PRM_WrapperForTrainingDetails wrpr;
        for( k_v_f_training_detail_sfdcs__x td : lstOfTrainingDetails){
            if(td.value_exchange_period_txt__c==Label.PRM_Previous_Measurement_Period){
                MeasurementPeriod=system.Label.PRM_Dash_MeasurementPeriod_Prev; 
            }   
            else if(td.value_exchange_period_txt__c==Label.PRM_Current_measurement_period){
                MeasurementPeriod=system.Label.PRM_Dash_MeasurementPeriod_Current; 
            }
            wrpr = new PRM_WrapperForTrainingDetails();
            wrpr.account_number = td.business_organization_party_id__r.AccountNumber;//account_number
            wrpr.contact_name = td.business_person_id__r.Name;//contact_name
            wrpr.training_id = td.training_id__c;//training_id
            wrpr.training_name = td.training_nm__c;//training_name
            wrpr.training_credits =(Decimal) td.training_credit_qty__c;//training_credits
            wrpr.training_completion_date = td.training_complete_dt__c;//training_completion_date
            wrpr.Measurement_Period=MeasurementPeriod;
            wrapper.add(wrpr);
        }
        return wrapper;
    }
    public class TrainingParentWrapper{
        @AuraEnabled
        public Boolean limitBreachedTraining;
        @AuraEnabled
        public List<PRM_WrapperForTrainingDetails> wrapTraining;
    }
    
    public static string getContactId(){
        User user = [select Id/*,Name*/,ContactId from User where Id = :UserInfo.getUserId()];//ATHR Fix - TWC729-9556 - SJ
        return user.ContactId;
    }
    
    private static Integer getCount(List<k_v_f_training_detail_sfdcs__x> lstTraining,String startDate, String endDate){
        Integer cnt = 0;
        if(String.isEmpty(startDate) || String.isEmpty(endDate) || startDate == null || endDate == null){
            for( k_v_f_training_detail_sfdcs__x kvfTraining : lstTraining ){ 
                cnt ++;
            }
        }else{
            for( k_v_f_training_detail_sfdcs__x kvfTraining : lstTraining){ 
                if(kvfTraining.training_complete_dt__c <= endDate && kvfTraining.training_complete_dt__c >= startDate){
                    cnt ++;
                }
            }
        }
        return cnt;
    }
    
    //used to get no of records
    @AuraEnabled
    public static Integer recordsCount(String startDate, String endDate){//
        String username = getContactId();
        List<k_v_f_training_detail_sfdcs__x> lstTraining = [select Id,training_complete_dt__c,training_id__c,business_person_id__c from k_v_f_training_detail_sfdcs__x 
                                                            where business_person_id__c = :username order by training_id__c];
        
        if(Test.isRunningTest()){
            lstTraining = trainingMocked;
        }
        Integer cnt = getCount(lstTraining, startDate, endDate);
        
        return cnt;
    }
    
   
    public with sharing class PRM_WrapperForTrainingDetails {
        @auraEnabled public String account_number {get;set;}//account_number
        @auraEnabled public string contact_name {get;set;}//contact_name
        @auraEnabled public string training_id {get;set;}//training_id
        @auraEnabled public string training_name {get;set;}//training_name
        @auraEnabled public Decimal training_credits {get;set;}//training_credits
        @auraEnabled public string training_completion_date {get;set;}//training_completion_date
        @auraEnabled public string Measurement_Period {get;set;}
    }
    public with sharing class PRM_WrapperForSalesgDetails {
        @auraEnabled public String invoice_number {get;set;}//invoice_number
        @auraEnabled public String distributor_name {get;set;}//distributor_name
        @auraEnabled public String form_factor {get;set;}//form_factor
        @auraEnabled public string account_number {get;set;}//account_number
        @auraEnabled public string intel_brand {get;set;}//intel_brand
        @auraEnabled public string product_number {get;set;}//product_number
        @auraEnabled public string invoice_date {get;set;}//invoice_date
        @auraEnabled public Decimal sales_out_units {get;set;}//sales_out_units
        @auraEnabled public string sales_type {get;set;}//sales_type
        @auraEnabled public String productOrderingCode {get;set;}
        @auraEnabled public string productCodeNumber {get;set;}
        @auraEnabled public string Measurement_Period {get;set;}
    }
    
    
    @AuraEnabled
    public static SalesParentWrapper getExtSalesDetails1(String invoiceNumber, String lastInv,String prevInv,String prevInv1,Integer pageSize,String startDate, String endDate, Boolean isDownload, String lastInvtoPass){
        List<k_v_f_detail_value_exchange_sfdcs__x> lstOfSalesDetails = new List<k_v_f_detail_value_exchange_sfdcs__x>();
        List<PRM_WrapperForSalesgDetails> salesWrapper = new List<PRM_WrapperForSalesgDetails>();
        SalesParentWrapper parentWrap = new SalesParentWrapper();
        Set<String> stTypeCode = new Set<String>();
        Set<Id> accountIds = currentUserAccounts();
        // if(isDownload){
        //     accountIds.add('001o000000O6LEdAAN'); 
        // }
        String inv =invoiceNumber;
        Integer pgSize = pageSize+1;
        Map<String, String> mp = new Map<String, String>();
        List<k_v_f_detail_value_exchange_sfdcs__x> lstVX =  new List<k_v_f_detail_value_exchange_sfdcs__x>();
        String query = 'select start_dt__c, value_exchange_period_txt__c,end_dt__c,item_id__c, old_material_id__c, business_organization_party_id__c,business_organization_party_id__r.AccountNumber, disti_nm__c,forecast_product_nbr__c, form_factor_txt__c,intel_brand_nm__c,invoice_nbr__c, product_sold_qty__c, sales_type_cd__c,invoice_dt__c from k_v_f_detail_value_exchange_sfdcs__x' +
        ' where (business_organization_party_id__c in:accountIds or one_partner_customer_aggregation_id__c in:accountIds)';

        
      //  System.debug('Last Invoice Number '+lastInv +'PageSize: '+pageSize+'Start Date :'+startDate+'End date :'+endDate+'Invoice Number :'+invoiceNumber+' Prev Inv'+prevInv+' Prev Inv1'+prevInv1);
        try{
            if(!String.isEmpty(lastInv) && (String.isEmpty(inv) || inv==null) &&!String.isEmpty(startDate) && !String.isEmpty(endDate) && (String.isEmpty(prevInv) && String.isEmpty(prevInv1))){
                
                if(isDownload == false && pageSize >0){
                    
                    query+= ' and invoice_nbr__c >: lastInv and (invoice_dt__c>=: startDate and invoice_dt__c <=:endDate ) order by invoice_dt__c desc NULLS LAST limit : pageSize';
                }else if(isDownload){
                    query+= ' and invoice_nbr__c >: lastInvtoPass and (invoice_dt__c>=: startDate and invoice_dt__c <=:endDate ) order by invoice_dt__c desc NULLS LAST limit : PRM_DashboardDownloadLimit';
                    // if(!isExport){
                    //     query+= ' limit : PRM_DashboardDownloadLimit';
                    // }
                }
            }else if(String.isEmpty(lastInv) && (String.isEmpty(inv) || inv==null) &&!String.isEmpty(startDate) && !String.isEmpty(endDate) && (!String.isEmpty(prevInv) && !String.isEmpty(prevInv1))){
                
                if(isDownload == false  && pageSize >0){
                    query+= ' and (invoice_nbr__c <:prevInv1 and invoice_nbr__c >=:prevInv) and (invoice_dt__c>=: startDate and invoice_dt__c <=:endDate ) order by invoice_dt__c desc NULLS LAST limit : pageSize';
                }else if(isDownload){
                    query+= ' and (invoice_nbr__c <:prevInv1 and invoice_nbr__c >=:prevInv) and (invoice_dt__c>=: startDate and invoice_dt__c <=:endDate ) order by invoice_dt__c desc NULLS LAST limit : PRM_DashboardDownloadLimit';
                    // if(!isExport){
                    //     query+= ' limit : PRM_DashboardDownloadLimit';
                    // }
                }
                
            //changesss    
            }else if(String.isEmpty(lastInv) && (String.isEmpty(inv) || inv==null) &&String.isEmpty(startDate) && String.isEmpty(endDate) && (String.isEmpty(prevInv) && String.isEmpty(prevInv1))){
                
                if(isDownload == false  && pageSize >0){
                    query+= ' order by invoice_dt__c desc NULLS LAST limit : pageSize';
                }else if(isDownload){
                    query+= 'and (invoice_nbr__c >= :lastInvtoPass) order by invoice_dt__c desc NULLS LAST limit : PRM_DashboardDownloadLimit';
                    // if(!isExport){
                    //     query+= ' limit : PRM_DashboardDownloadLimit';
                    // }
                }
                
                
            }else if(!String.isEmpty(lastInv) && (String.isEmpty(inv) || inv==null) &&String.isEmpty(startDate) && String.isEmpty(endDate) && (String.isEmpty(prevInv) && String.isEmpty(prevInv1))){
               
                if(isDownload == false  && pageSize >0){
                    query+= ' and invoice_nbr__c > :lastInv order by invoice_dt__c desc NULLS LAST limit : pageSize';
                }else if(isDownload){
                    query+= ' and invoice_nbr__c >= :lastInvtoPass order by invoice_dt__c desc NULLS LAST limit : PRM_DashboardDownloadLimit';
                    // if(!isExport){
                    //     query+= ' limit : PRM_DashboardDownloadLimit';
                    // }
                }
            }else if((!String.isEmpty(inv) || inv!=null) && String.isEmpty(lastInv) &&String.isEmpty(startDate)&&String.isEmpty(endDate) && (String.isEmpty(prevInv) && String.isEmpty(prevInv1))){
                
                if(isDownload == false  && pageSize >0){
                    query+= ' and invoice_nbr__c =: inv order by invoice_dt__c desc NULLS LAST limit : pageSize';
                }else if(isDownload){
                    query+= ' and invoice_nbr__c =: inv order by invoice_dt__c desc NULLS LAST limit : PRM_DashboardDownloadLimit';
                    // if(!isExport){
                    //     query+= ' limit : PRM_DashboardDownloadLimit';
                    // }
                }
            }else if((!String.isEmpty(inv)) && String.isEmpty(lastInv) && !String.isEmpty(startDate)&& !String.isEmpty(endDate) && (String.isEmpty(prevInv) && String.isEmpty(prevInv1))){
                
                if(isDownload == false  && pageSize >0){
                    query+= ' and invoice_nbr__c =: inv  and invoice_dt__c>=: startDate and invoice_dt__c <=:endDate order by invoice_dt__c desc NULLS LAST limit : pageSize';
                }else if(isDownload){
                    query+= ' and invoice_nbr__c =: inv  and invoice_dt__c>=: startDate and invoice_dt__c <=:endDate order by invoice_dt__c desc NULLS LAST limit : PRM_DashboardDownloadLimit';
                    // if(!isExport){
                    //     query+= ' limit : PRM_DashboardDownloadLimit';
                    // }
                }
                
            }else if((String.isEmpty(prevInv1) || prevInv1==null) && String.isEmpty(lastInv) && !String.isEmpty(startDate)&& !String.isEmpty(endDate) && (String.isEmpty(prevInv) && String.isEmpty(prevInv1))){
                
                if(isDownload == false  && pageSize >0){
                    query+= ' and invoice_dt__c>= : startDate and invoice_dt__c <= :endDate order by invoice_dt__c desc NULLS LAST limit : pageSize';
                }else if(isDownload){
                    query+= ' and invoice_dt__c>= : startDate and invoice_dt__c <= :endDate order by invoice_dt__c desc NULLS LAST limit : PRM_DashboardDownloadLimit';
                    // if(!isExport){
                    //     query+= ' limit : PRM_DashboardDownloadLimit';
                    // }
                }
                
            }else if((String.isEmpty(inv) || inv==null)&&(String.isEmpty(inv) || inv==null) && String.isEmpty(lastInv) && String.isEmpty(startDate)&& String.isEmpty(endDate) && ((!String.isEmpty(prevInv) || prevInv !=null) && (!String.isEmpty(prevInv1) || prevInv1!=null))){
                
                if(isDownload == false  && pageSize >0){
                    query+= ' and (invoice_nbr__c <:prevInv1 and invoice_nbr__c>= :prevInv)  order by invoice_dt__c desc NULLS LAST limit : pageSize';
                }else if(isDownload){
                    query+= ' and (invoice_nbr__c <:prevInv1 and invoice_nbr__c>= :prevInv)  order by invoice_dt__c desc NULLS LAST limit : PRM_DashboardDownloadLimit';
                    // if(!isExport){
                    //     query+= ' limit : PRM_DashboardDownloadLimit';
                    // }
                }   
            }
             List<k_v_f_detail_value_exchange_sfdcs__x> kvfQuery = new List<k_v_f_detail_value_exchange_sfdcs__x>();
                if (isDownload) {
                        for (k_v_f_detail_value_exchange_sfdcs__x kvf: database.query(query)) {
                            kvfQuery.add(kvf);
                        }
                    system.debug(LoggingLevel.info,'kvfQuerysize'+kvfQuery.size());
                }else{
                    kvfQuery = database.query(query);
                }
                
                if(kvfQuery.size()>0 && !kvfQuery.isEmpty()){
                for(k_v_f_detail_value_exchange_sfdcs__x kv :kvfQuery){
                                                                  lstOfSalesDetails.add(kv);stTypeCode.add(kv.sales_type_cd__c);
                                                              }
                                                            }
                
                if(Test.isRunningTest()){
                    for(k_v_f_detail_value_exchange_sfdcs__x kv : salesMocked){
                        lstOfSalesDetails.add(kv);
                        stTypeCode.add(kv.sales_type_cd__c);
                    }
                }

        }catch(Exception ex){
            System.debug('Error :'+ex.getMessage());
        }
        try{
            for(PRM_Sales_Calculation_Group__c  revenueSource : [select id,PRM_Revenue_Source_Nm__c, PRM_Sales_Calculation_Group_Nm__c 
                                                                 from PRM_Sales_Calculation_Group__c where PRM_Sales_Calculation_Group_Nm__c in :stTypeCode order by id]){
                                                                     if(!mp.containsKey(revenueSource.PRM_Sales_Calculation_Group_Nm__c)){
                                                                         mp.put(revenueSource.PRM_Sales_Calculation_Group_Nm__c, revenueSource.PRM_Revenue_Source_Nm__c);
                                                                     }
                                                                 }
            System.debug(' Map : '+mp);
            
            PRM_WrapperForSalesgDetails salesWrpr;
            System.debug('>>>lstOfSalesDetails'+lstOfSalesDetails.size());
            if(!lstOfSalesDetails.isEmpty() && lstOfSalesDetails!=null){

                for( k_v_f_detail_value_exchange_sfdcs__x sd : lstOfSalesDetails){
                    if(sd.value_exchange_period_txt__c==Label.PRM_Previous_Measurement_Period){
                       MeasurementPeriod=system.Label.PRM_Dash_MeasurementPeriod_Prev; 
                    }   
                    else if(sd.value_exchange_period_txt__c==Label.PRM_Current_measurement_period){
                        MeasurementPeriod=system.Label.PRM_Dash_MeasurementPeriod_Current; 
                    }
                    if(Date.valueOf(sd.start_dt__c).month()>=Integer.valueOf(Label.PRM_Vx_Frommonth_for_Report) 
                    && Date.valueOf(sd.end_dt__c).month()<=Integer.valueOf(Label.PRM_Vx_Tomonth_for_Report) 
                  /*  && (Date.valueOf(sd.start_dt__c).year()==system.today().year()-2 
                        && Date.valueOf(sd.end_dt__c).year()==(system.today().year()-1)) 
                    || (Date.valueOf(sd.start_dt__c).year()==system.today().year()-1 
                        && Date.valueOf(sd.end_dt__c).year()==(system.today().year()))){ */
                        
                        && (String.valueOf(Date.valueOf(sd.start_dt__c).year())==Label.PRM_Previous_Measurement_Period.split('-')[0].split(' ')[1] 
                        && String.valueOf(Date.valueOf(sd.end_dt__c).year())==Label.PRM_Previous_Measurement_Period.split('-')[1].split(' ')[2]) 
                    || (String.valueOf(Date.valueOf(sd.start_dt__c).year())==Label.PRM_Current_measurement_period.split('-')[0].split(' ')[1] 
                        && String.valueOf(Date.valueOf(sd.end_dt__c).year())==Label.PRM_Current_measurement_period.split('-')[1].split(' ')[2])){ 
                        
                        salesWrpr = new PRM_WrapperForSalesgDetails();
                        salesWrpr.account_number = sd.business_organization_party_id__r.AccountNumber;//account_number
                        salesWrpr.invoice_date = sd.invoice_dt__c;//invoice_date
                        salesWrpr.form_factor = sd.form_factor_txt__c;//form_factor
                        salesWrpr.intel_brand = sd.intel_brand_nm__c;//intel_brand
                        salesWrpr.product_number = sd.forecast_product_nbr__c;//product_number
                        salesWrpr.sales_out_units = sd.product_sold_qty__c;//sales_out_units
                        salesWrpr.distributor_name = sd.disti_nm__c;//distributor_name
                        salesWrpr.invoice_number = sd.invoice_nbr__c;//invoice_number
                        salesWrpr.productOrderingCode = sd.old_material_id__c;//invoice_number
                        salesWrpr.productCodeNumber = sd.item_id__c;//invoice_number
                        salesWrpr.sales_type = mp.get(sd.sales_type_cd__c);//sales_type --> revenue source
                        salesWrpr.Measurement_Period=MeasurementPeriod;
                        salesWrapper.add(salesWrpr);
                    }
                }
                parentWrap.limitBreached = lstOfSalesDetails.size() >= PRM_DashboardDownloadLimit ? true : false;
                parentWrap.wrap = salesWrapper;
            }
            
        }catch(Exception ex){
            System.debug('Error :'+ex.getMessage());
        }
        return parentWrap;
    }

    public class SalesParentWrapper{
        @AuraEnabled
        public Boolean limitBreached;
        @AuraEnabled
        public List<PRM_WrapperForSalesgDetails> wrap;
    }
}