public without sharing class  PRM_Externa_Objects_Data  {
    
    static FINAL String ADMIN = 'IT Admin';   
    static FINAL String SYSADMIN = 'System Administrator';
    //get the list account numbers for Loading account wise on Company_training_credits LWC --
    @AuraEnabled
    public static List<PRM_AccountsList> getLstActNumber(){//used
        Set<Id> accountIds = currentUserAccounts();
        List<PRM_AccountsList> accountNumber = new List<PRM_AccountsList>();
        PRM_AccountsList act = new PRM_AccountsList();
        try{
            for(Account actList : [select accountnumber from account where id in :accountIds]){
                act.sAccountNo = actList.accountnumber;
                accountNumber.add(act);
            }
        }catch(Exception ex){
            System.debug('Error: '+ex.getMessage());
        }
        return accountNumber;
    }
    
    //to get the dynamic URL  --
    @AuraEnabled
    public static String getPageURL(){
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        String url = '/ipa/s/training-credits';
        return baseUrl+url;
    }
    
    //get the Logged in Users Accout which are associated to him
    //will return Account list if contact is part of OPID
    //otherwise will return Account Id he is part of
    private static Set<Id> currentUserAccounts(){
        Set<Id> accountIds = new Set<Id>();
        User user = [select Id, username,Core_IPA_One_Partner_Id__c,Core_IPS_AccountId__c from User where Id = :UserInfo.getUserId()];//where Id =: currentUserId
        if(user.Core_IPA_One_Partner_Id__c != null){
            
            for(Core_Account_Group_Member__c agm : [select Core_Intel_Account_Id__c from Core_Account_Group_Member__c where Core_Partner_Account_Id__c =:user.Core_IPA_One_Partner_Id__c ]){
                accountIds.add(agm.Core_Intel_Account_Id__c);
            }
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
        System.debug('deployed');
        String username = getContactName();
        Integer sum =0;
        for( k_v_f_training_detail_sfdcs__x lstKvfTd : [select training_credit_qty__c,business_person_id__r.Name
                                                        from  k_v_f_training_detail_sfdcs__x where business_person_id__r.Name =: username
                                                        order by training_id__c]){
                                                            sum+=(Integer)lstKvfTd.training_credit_qty__c;
                                                        }
        return sum;
    }
    
    
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
            System.debug('List is Empty...');
        }
        System.debug(' List'+ lstOfTrainingDetails);
        
        PRM_WrapperForTrainingDetails wrpr;
        for( k_v_f_training_detail_sfdcs__x td : lstOfTrainingDetails){
            wrpr = new PRM_WrapperForTrainingDetails();
            wrpr.sAccountNo = td.business_organization_party_id__r.AccountNumber;
            wrpr.sContactName = td.business_person_id__r.Name;
            wrpr.sTrainingId = td.training_id__c;
            wrpr.sTrainingName = td.training_nm__c;
            wrpr.sTrainingCredits =(Decimal) td.training_credit_qty__c;
            wrpr.sTrainingComplDate = td.training_complete_dt__c;
            wrapper.add(wrpr);
        }
        return wrapper;
    }
    
    
    // this will return all the data for the OPID members 
    // this method is used in member-training-details LWC component --
    @auraEnabled(Cacheable = true)
    public static List<PRM_WrapperForTrainingDetails> getExternalOPIDTrainingDetails(){//
        Set<Id> accountIds = currentUserAccounts();
        System.debug('You are inside this method from LWC');
        
        List<k_v_f_training_detail_sfdcs__x> kvfTraining = [select business_person_id__r.Name,training_id__c,training_complete_dt__c, training_nm__c, business_organization_party_id__r.AccountNumber,training_credit_qty__c
                                                            from  k_v_f_training_detail_sfdcs__x where business_organization_party_id__c in : accountIds order by training_id__c NULLS LAST];
        
        List<PRM_WrapperForTrainingDetails> wrapper = getWrapperData(kvfTraining, '', '');
        return wrapper;
    }
    
    
    //this method will return external sales details --
    @AuraEnabled
    public static List<PRM_WrapperForSalesgDetails> getExternalSalesDetails(Integer pagenumber, Integer numberOfRecords, Integer pageSize, String startDate, String endDate, String invoiceNumber){
        List<k_v_f_detail_value_exchange_sfdcs__x> lstOfSalesDetails = new List<k_v_f_detail_value_exchange_sfdcs__x>();
        List<PRM_WrapperForSalesgDetails> salesWrapper = new List<PRM_WrapperForSalesgDetails>();
        Set<String> stTypeCode = new Set<String>();
        Set<Id> accountIds = currentUserAccounts();
        String inv =invoiceNumber;
        
        List<k_v_f_detail_value_exchange_sfdcs__x> lstVX = [select business_organization_party_id__r.AccountNumber, disti_nm__c,forecast_product_nbr__c, form_factor_txt__c,intel_brand_nm__c,
                                                            invoice_nbr__c, product_sold_qty__c, sales_type_cd__c,invoice_dt__c
                                                            from k_v_f_detail_value_exchange_sfdcs__x 
                                                            where business_organization_party_id__c in:accountIds order 
                                                            by invoice_nbr__c limit : pageSize offset: (pageSize *( pagenumber -1 ))];
        if(lstVX!=null && lstVX.size() > 0){
            if(String.isEmpty(invoiceNumber) && (String.isEmpty(startDate) || String.isEmpty(endDate) )){
                System.debug(' for all empty conditions');
                for(k_v_f_detail_value_exchange_sfdcs__x vx : lstVX){
                    lstOfSalesDetails.add(vx);
                    stTypeCode.add(vx.sales_type_cd__c);
                }
            }else if(String.isEmpty(invoiceNumber) && (!String.isEmpty(startDate) && !String.isEmpty(endDate)) ){
                System.debug(' for invoice empty conditions');
                for(k_v_f_detail_value_exchange_sfdcs__x vx : lstVX){
                    if(vx.invoice_dt__c>=startDate && vx.invoice_dt__c<=endDate){
                        lstOfSalesDetails.add(vx);
                        stTypeCode.add(vx.sales_type_cd__c);
                    }
                }
            }else if(!String.isEmpty(invoiceNumber) && (String.isEmpty(startDate) && String.isEmpty(endDate)) ){
                System.debug(' for date empty conditions');
                for(k_v_f_detail_value_exchange_sfdcs__x vx : lstVX){
                    if(vx.invoice_nbr__c ==inv){
                        lstOfSalesDetails.add(vx);
                        stTypeCode.add(vx.sales_type_cd__c);
                    }
                }
            }else{
                if(!String.isEmpty(invoiceNumber) && (!String.isEmpty(startDate) && !String.isEmpty(endDate)) ){
                    System.debug(' for all true conditions');
                    for(k_v_f_detail_value_exchange_sfdcs__x vx : lstVX){
                        if(vx.invoice_nbr__c ==inv && (vx.invoice_dt__c>=startDate && vx.invoice_dt__c<=endDate)){
                            lstOfSalesDetails.add(vx);
                            stTypeCode.add(vx.sales_type_cd__c);
                        }
                    }
                }
            }
        }else{
            System.debug('No Records found...');
        }
        
        System.debug(' List of sales'+ lstOfSalesDetails.size() );
        System.debug(' List of accounts ids :'+accountIds);
        
        List<PRM_Sales_Calculation_Group__c>  revenueSource = [select id,PRM_Revenue_Source_Nm__c, PRM_Sales_Calculation_Group_Nm__c 
                                                               from PRM_Sales_Calculation_Group__c where PRM_Sales_Calculation_Group_Nm__c in :stTypeCode order by id];
        
        PRM_WrapperForSalesgDetails salesWrpr;
        if(revenueSource!=null && !revenueSource.isEmpty() && !revenueSource.isEmpty() && lstOfSalesDetails!=null){
            for( k_v_f_detail_value_exchange_sfdcs__x sd : lstOfSalesDetails){
                salesWrpr = new PRM_WrapperForSalesgDetails();
                salesWrpr.sAccountNo = sd.business_organization_party_id__r.AccountNumber;
                salesWrpr.sInvoiceDate = sd.invoice_dt__c;
                salesWrpr.sFormFactor = sd.form_factor_txt__c;
                salesWrpr.sIntelBrand = sd.intel_brand_nm__c;
                salesWrpr.sProductNumber = sd.forecast_product_nbr__c;
                salesWrpr.sSalesOutUnits = sd.product_sold_qty__c;
                salesWrpr.sDistributorName = sd.disti_nm__c;
                salesWrpr.sInvoiceNumber = sd.invoice_nbr__c;
                for(PRM_Sales_Calculation_Group__c scg : revenueSource){
                    if(scg.PRM_Sales_Calculation_Group_Nm__c == sd.sales_type_cd__c){
                        salesWrpr.sSalesType = scg.PRM_Revenue_Source_Nm__c;
                        break;
                    }
                }
                salesWrapper.add(salesWrpr);
                
            }
        }
        System.debug('Sales wrapper :'+salesWrapper);
        //return currentUserId;
        return salesWrapper;
    }
    //to get the contact training details
    @auraEnabled(Cacheable = true)
    public static List<PRM_WrapperForTrainingDetails> getExternalTrainingDetails(Integer pagenumber, Integer numberOfRecords, Integer pageSize, String startDate, String endDate){//
        String username = getContactName();
        //-------variables for training details starts here ------------isem
        List<PRM_WrapperForTrainingDetails> wrapper = new List<PRM_WrapperForTrainingDetails>();
        List<k_v_f_training_detail_sfdcs__x> lstOfTrainingDetails = new List<k_v_f_training_detail_sfdcs__x>();
        Map<String,String> mpContactName =  new Map<String, String>();
        ///-------variables for training details end here ------
        set<id> actId = currentUserAccounts();
        System.debug('You are inside this method from LWC');
        List<k_v_f_training_detail_sfdcs__x> lstTrainingDetails = new List<k_v_f_training_detail_sfdcs__x>();
        
        List<k_v_f_training_detail_sfdcs__x> kvfTraining = [select business_person_id__r.Name,training_id__c,training_complete_dt__c, training_nm__c, business_organization_party_id__r.AccountNumber,training_credit_qty__c
                                                            from  k_v_f_training_detail_sfdcs__x where business_person_id__r.Name = :username order by training_id__c limit : pageSize offset: (pageSize *( pagenumber -1 ))];
        
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
        System.debug(' List'+ lstOfTrainingDetails);
        
        PRM_WrapperForTrainingDetails wrpr;
        for( k_v_f_training_detail_sfdcs__x td : lstOfTrainingDetails){
            wrpr = new PRM_WrapperForTrainingDetails();
            wrpr.sAccountNo = td.business_organization_party_id__r.AccountNumber;
            wrpr.sContactName = td.business_person_id__r.Name;
            wrpr.sTrainingId = td.training_id__c;
            wrpr.sTrainingName = td.training_nm__c;
            wrpr.sTrainingCredits =(Decimal) td.training_credit_qty__c;
            wrpr.sTrainingComplDate = td.training_complete_dt__c;
            wrapper.add(wrpr);
        }
        return wrapper;
    }
    
    public static string getContactName(){
        User user = [select Id,Name from User where Id = :UserInfo.getUserId()];
        return user.Name;
    }
    
    private static Integer getCount(List<k_v_f_training_detail_sfdcs__x> lstTraining,String startDate, String endDate){
        Integer cnt = 0;
        if(String.isEmpty(startDate) || String.isEmpty(endDate) || startDate == null || endDate == null){
            System.debug('Inside empty date');
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
        System.debug('count1 :'+cnt);
        return cnt;
    }
    
    @AuraEnabled
    public static Integer companyCreditsRecordsCount(String startDate, String endDate){//
        Set<Id> actsIds = currentUserAccounts();
        System.debug('You are inside this recordsCount from LWC trainig Start Date'+startDate+'End Date'+endDate);
        
        
        List<k_v_f_training_detail_sfdcs__x> lstTraining = [select Id,training_complete_dt__c,training_id__c from k_v_f_training_detail_sfdcs__x 
                                                            where business_organization_party_id__c in :actsIds order by training_id__c];
        Integer cnt = getCount(lstTraining, startDate, endDate);
        
        return cnt;
    }
    
    
    //used to get no of records
    @AuraEnabled
    public static Integer recordsCount(String startDate, String endDate){//
        String username = getContactName();
        System.debug('You are inside this recordsCount from LWC trainig Start Date'+startDate+'End Date'+endDate);
        List<k_v_f_training_detail_sfdcs__x> lstTraining = [select Id,training_complete_dt__c,training_id__c from k_v_f_training_detail_sfdcs__x 
                                                            where business_person_id__r.Name = :username order by training_id__c];
        Integer cnt = getCount(lstTraining, startDate, endDate);
        
        return cnt;
    }
    
    // getting sales records count
    @AuraEnabled(Cacheable=true)
    public static Integer salesRecordsCount(String startDate, String endDate, String invoiceNumber){//
        Set<Id> accountIds = currentUserAccounts();
        System.debug('You are inside this recordsCount from LWC for sales Start Date'+startDate+'End Date'+endDate);
        Integer cnt = 0;
        String inv = invoiceNumber;
        Set<Id> acctId = new Set<Id>();
        List<Account> lstAccount = new List<Account>();
        
        List<k_v_f_detail_value_exchange_sfdcs__x> lstKVF = [select id,business_organization_party_id__c,invoice_nbr__c,invoice_dt__c  from k_v_f_detail_value_exchange_sfdcs__x 
                                                             where business_organization_party_id__c in :accountIds order by invoice_nbr__c];
        
        if(String.isBlank(invoiceNumber) &&(String.isBlank(startDate) || String.isBlank(endDate))){
            System.debug('Form connected callback');
            for( k_v_f_detail_value_exchange_sfdcs__x externalDetails : lstKVF){ 
                cnt ++;    
            }
        }
        else if(String.isBlank(invoiceNumber) && (!String.isBlank(startDate) && !String.isBlank(endDate)) ){
            System.debug('date');
            for( k_v_f_detail_value_exchange_sfdcs__x externalDetails : lstKVF){ 
                if( externalDetails.invoice_dt__c>=startDate && externalDetails.invoice_dt__c<=endDate){
                    cnt ++;
                }
            }
            System.debug('Count :'+ cnt);
            System.debug('count of inv nmbr :'+cnt);
        }
        
        else if((String.isBlank(startDate) || (String.isBlank(endDate)) && !String.isBlank(invoiceNumber)) ){
            System.debug('Invoice number ');
            for( k_v_f_detail_value_exchange_sfdcs__x externalDetails :lstKVF){ 
                if(externalDetails.invoice_nbr__c == invoiceNumber){
                    cnt ++;    
                }
            }
            System.debug('count :'+cnt);
        }
        else{
            if(!String.isBlank(startDate)&& !String.isBlank(endDate) && !String.isBlank(invoiceNumber)){
                System.debug('Date and inv');
                for( k_v_f_detail_value_exchange_sfdcs__x externalDetails : lstKVF){
                    if(externalDetails.invoice_dt__c >= startDate && externalDetails.invoice_dt__c<= endDate && externalDetails.invoice_nbr__c == invoiceNumber){cnt ++;    }
                }
                System.debug('count :'+cnt);
            }
        }
        return cnt;
    }
    
    
    //wrapper for account
    public with sharing class PRM_AccountsList{
        @auraEnabled public String sAccountNo {get;set;}
    }
    
    public with sharing class PRM_WrapperForTrainingDetails {
        @auraEnabled public String sAccountNo {get;set;}
        @auraEnabled public string sContactName {get;set;}
        @auraEnabled public string sTrainingId {get;set;}
        @auraEnabled public string sTrainingName {get;set;}
        @auraEnabled public Decimal sTrainingCredits {get;set;}
        @auraEnabled public string sTrainingComplDate {get;set;}
        @auraEnabled public string sExtId {get;set;}
    }
    public with sharing class PRM_WrapperForSalesgDetails {
        @auraEnabled public String sInvoiceNumber {get;set;}
        @auraEnabled public String sDistributorName {get;set;}
        @auraEnabled public String sFormFactor {get;set;}
        @auraEnabled public string sAccountNo {get;set;}
        @auraEnabled public string sIntelBrand {get;set;}
        @auraEnabled public string sProductNumber {get;set;}
        @auraEnabled public string sInvoiceDate {get;set;}
        @auraEnabled public Decimal sSalesOutUnits {get;set;}
        @auraEnabled public string sSalesType {get;set;}
    }
  
    @AuraEnabled
    public static List<PRM_WrapperForSalesgDetails> getExtSalesDetails(String invoiceNumber, String lastInv,String prevInv,Integer pageSize,String startDate, String endDate){
        List<k_v_f_detail_value_exchange_sfdcs__x> lstOfSalesDetails = new List<k_v_f_detail_value_exchange_sfdcs__x>();
        List<PRM_WrapperForSalesgDetails> salesWrapper = new List<PRM_WrapperForSalesgDetails>();
        Set<String> stTypeCode = new Set<String>();
        Set<Id> accountIds = currentUserAccounts();
        String inv =invoiceNumber;
        List<k_v_f_detail_value_exchange_sfdcs__x> lstVX =  new List<k_v_f_detail_value_exchange_sfdcs__x>();
        
        System.debug('Last Invoice Number '+lastInv +'PageSize: '+pageSize+'Start Date :'+startDate+'End date :'+endDate+'Invoice Number :'+invoiceNumber+' Prev Inv'+prevInv);
        try{
            if(String.isEmpty(lastInv) && pageSize >0 && (String.isEmpty(inv) || inv==null) &&String.isEmpty(startDate) && String.isEmpty(endDate) && (String.isEmpty(prevInv))){
                System.debug('Empty invoice');
                for(k_v_f_detail_value_exchange_sfdcs__x kv :[select business_organization_party_id__r.AccountNumber, disti_nm__c,forecast_product_nbr__c, form_factor_txt__c,intel_brand_nm__c,
                                                              invoice_nbr__c, product_sold_qty__c, sales_type_cd__c,invoice_dt__c
                                                              from k_v_f_detail_value_exchange_sfdcs__x 
                                                              where business_organization_party_id__c in:accountIds order 
                                                              by invoice_nbr__c NULLS LAST  LIMIT  201]){
                                                                  lstOfSalesDetails.add(kv);
                                                                  stTypeCode.add(kv.sales_type_cd__c);
                                                              }
                System.debug(' List of sales :'+lstOfSalesDetails.size());                                              
                System.debug(' List of sales :'+lstOfSalesDetails);
                
                    
            }else if(!String.isEmpty(lastInv) && pageSize >0 && (String.isEmpty(inv) || inv==null) &&String.isEmpty(startDate) && String.isEmpty(endDate) && (String.isEmpty(prevInv)) ){
                System.debug('next');
                
                System.debug(' Last Invoice :'+lastInv);
                System.debug(' List in next :'+lstVX);
                for(k_v_f_detail_value_exchange_sfdcs__x vx : [select business_organization_party_id__r.AccountNumber, disti_nm__c,forecast_product_nbr__c, form_factor_txt__c,intel_brand_nm__c,
                                                               invoice_nbr__c, product_sold_qty__c, sales_type_cd__c,invoice_dt__c
                                                               from k_v_f_detail_value_exchange_sfdcs__x 
                                                               where business_organization_party_id__c in:accountIds and invoice_nbr__c > :lastInv order 
                                                               by invoice_nbr__c NULLS LAST LIMIT 201]){
                                                                   lstOfSalesDetails.add(vx);
                                                                   stTypeCode.add(vx.sales_type_cd__c);
                                                                   
                                                                   
                                                               }
                System.debug('lst of sales :'+lstOfSalesDetails);
                System.debug('lst of codes :'+stTypeCode);
            }else if((!String.isEmpty(inv) || inv!=null) && String.isEmpty(lastInv) &&String.isEmpty(startDate)&&String.isEmpty(endDate) && (String.isEmpty(prevInv))){
                System.debug('From single Invoice number');
                System.debug(' Last Invoice :'+inv);
                System.debug(' Account ids :'+accountIds);
                for( k_v_f_detail_value_exchange_sfdcs__x vx : [select business_organization_party_id__r.AccountNumber, disti_nm__c,forecast_product_nbr__c, form_factor_txt__c,intel_brand_nm__c,
                                                                invoice_nbr__c, product_sold_qty__c, sales_type_cd__c,invoice_dt__c
                                                                from k_v_f_detail_value_exchange_sfdcs__x 
                                                                where business_organization_party_id__c in:accountIds and invoice_nbr__c =: inv order 
                                                                by invoice_nbr__c NULLS LAST]){
                                                                    lstOfSalesDetails.add(vx);
                                                                    stTypeCode.add(vx.sales_type_cd__c);
                                                                }
                 System.debug('lst of sales :'+lstOfSalesDetails);
                System.debug('lst of codes :'+stTypeCode);
            }else if((!String.isEmpty(inv)) && String.isEmpty(lastInv) && !String.isEmpty(startDate)&& !String.isEmpty(endDate) && (String.isEmpty(prevInv))){
                System.debug('From all the filters...');
                for(k_v_f_detail_value_exchange_sfdcs__x vx :  [select business_organization_party_id__r.AccountNumber, disti_nm__c,forecast_product_nbr__c, form_factor_txt__c,intel_brand_nm__c,
                                                                invoice_nbr__c, product_sold_qty__c, sales_type_cd__c,invoice_dt__c
                                                                from k_v_f_detail_value_exchange_sfdcs__x 
                                                                where business_organization_party_id__c in:accountIds and invoice_nbr__c =: inv  and invoice_dt__c>=: startDate and invoice_dt__c <=:endDate order 
                                                                by invoice_nbr__c NULLS LAST LIMIT 201]){
                                                                    lstOfSalesDetails.add(vx);
                                                                    stTypeCode.add(vx.sales_type_cd__c);
                                                                    
                                                                } 
            }else if((String.isEmpty(inv) || inv==null) && String.isEmpty(lastInv) && !String.isEmpty(startDate)&& !String.isEmpty(endDate) && (String.isEmpty(prevInv))){
                System.debug('From and To dates');
                
                for(k_v_f_detail_value_exchange_sfdcs__x vx :  [select business_organization_party_id__r.AccountNumber, disti_nm__c,forecast_product_nbr__c, form_factor_txt__c,intel_brand_nm__c,
                                                                invoice_nbr__c, product_sold_qty__c, sales_type_cd__c,invoice_dt__c
                                                                from k_v_f_detail_value_exchange_sfdcs__x 
                                                                where business_organization_party_id__c in:accountIds and invoice_dt__c>= : startDate and invoice_dt__c <= :endDate order
                                                                by invoice_nbr__c NULLS LAST LIMIT 201]){
                                                                    lstOfSalesDetails.add(vx);
                                                                    stTypeCode.add(vx.sales_type_cd__c);
                                                                }
            }else if((String.isEmpty(inv) || inv==null) && String.isEmpty(lastInv) && String.isEmpty(startDate)&& String.isEmpty(endDate) && (!String.isEmpty(prevInv) || prevInv !=null)){
                System.debug('Prev');
                
                for(k_v_f_detail_value_exchange_sfdcs__x vx :  [select business_organization_party_id__r.AccountNumber, disti_nm__c,forecast_product_nbr__c, form_factor_txt__c,intel_brand_nm__c,
                                                                invoice_nbr__c, product_sold_qty__c, sales_type_cd__c,invoice_dt__c
                                                                from k_v_f_detail_value_exchange_sfdcs__x 
                                                                where business_organization_party_id__c in:accountIds and invoice_nbr__c< :prevInv  order 
                                                                by invoice_nbr__c NULLS LAST LIMIT 201]){
                                                                    lstOfSalesDetails.add(vx);
                                                                    stTypeCode.add(vx.sales_type_cd__c);
                                                                }
            }
        }catch(Exception ex){
            System.debug('Error :'+ex.getMessage());
        }
        System.debug(' List of sales'+ lstOfSalesDetails.size() );
        System.debug(' List of accounts ids :'+accountIds);
        try{
            List<PRM_Sales_Calculation_Group__c>  revenueSource = [select id,PRM_Revenue_Source_Nm__c, PRM_Sales_Calculation_Group_Nm__c 
                                                                   from PRM_Sales_Calculation_Group__c where PRM_Sales_Calculation_Group_Nm__c in :stTypeCode order by id NULLS LAST];
            
            PRM_WrapperForSalesgDetails salesWrpr;
            if(revenueSource!=null && !revenueSource.isEmpty() && !revenueSource.isEmpty() && lstOfSalesDetails!=null){
                for( k_v_f_detail_value_exchange_sfdcs__x sd : lstOfSalesDetails){
                    salesWrpr = new PRM_WrapperForSalesgDetails();
                    salesWrpr.sAccountNo = sd.business_organization_party_id__r.AccountNumber;
                    salesWrpr.sInvoiceDate = sd.invoice_dt__c;
                    salesWrpr.sFormFactor = sd.form_factor_txt__c;
                    salesWrpr.sIntelBrand = sd.intel_brand_nm__c;
                    salesWrpr.sProductNumber = sd.forecast_product_nbr__c;
                    salesWrpr.sSalesOutUnits = sd.product_sold_qty__c;
                    salesWrpr.sDistributorName = sd.disti_nm__c;
                    salesWrpr.sInvoiceNumber = sd.invoice_nbr__c;
                    for(PRM_Sales_Calculation_Group__c scg : revenueSource){
                        if(scg.PRM_Sales_Calculation_Group_Nm__c == sd.sales_type_cd__c){
                            salesWrpr.sSalesType = scg.PRM_Revenue_Source_Nm__c;
                            break;
                        }
                    }
                    salesWrapper.add(salesWrpr);
                    
                }
            }
        }catch(Exception ex){
            System.debug('Error :'+ex.getMessage());
        }
        System.debug('Sales wrapper :'+salesWrapper);
        
        //return currentUserId;
        return salesWrapper;
    }
    
}