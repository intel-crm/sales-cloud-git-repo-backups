public without sharing class UCD_AccountTypeDQ{

    public class combineWrapper{
        @AuraEnabled
        public Account acc {get;set;}
        @AuraEnabled
        public Integer score{get;set;}
        @AuraEnabled
        public Integer coreScore{get;set;}
        @AuraEnabled
        public Integer missScore{get;set;}
        @AuraEnabled
        public List<fieldData> MissingData{get;set;}
        @AuraEnabled
        public List<fieldData> CoreData{get;set;}
        @AuraEnabled
        public String AccountType{get;set;}
    }
    
    public class fieldData{
        @AuraEnabled
        public String FieldName {get;set;}
        @AuraEnabled
        public boolean isFilled {get;set;}
    }
    
     @AuraEnabled
    public static List<Integer> dashdata_core(List<combineWrapper> comwrap){
        
        integer tfcount = 0;
        integer ffcount = 0;
        integer sfcount = 0;
        integer hncount = 0;
        
        for(combineWrapper cw:comwrap){
            if(cw.coreScore == 100){
            system.debug('12345678'+cw.missScore);
                if(cw.missScore<= 25){
                    tfcount = tfcount+1;
                }
                else if(cw.missScore > 25 && cw.missScore <= 50){
                    ffcount= ffcount+1;
                }
                else if(cw.missScore > 50 && cw.missScore <= 75){
                    sfcount= sfcount+1;
                }
                else if(cw.missScore > 75 && cw.missScore <= 100){
                    hncount= hncount+1;
                }
            }
        }
            
        
        List<integer> datacount = new List<integer>();
        datacount.add(tfcount);
        datacount.add(ffcount);
        datacount.add(sfcount);
        datacount.add(hncount);
         
        return datacount;
        
    }
    //changing 
    @AuraEnabled
    public static List<Integer> dashdata(List<combineWrapper> comwrap){
    
        integer tfcount = 0;
        integer ffcount = 0;
        integer sfcount = 0;
        integer hncount = 0;
        
        for(combineWrapper cw:comwrap){
            if(cw.Score <= 25){
                tfcount = tfcount+1;
            }
        else if(cw.Score > 25 && cw.Score <= 50){
                ffcount= ffcount+1;
            }
        else if(cw.Score > 50 && cw.Score <= 75){
                sfcount= sfcount+1;
            }
        else if(cw.Score > 75 && cw.Score <= 100){
                hncount= hncount+1;
            }
        }
        
        List<integer> datacount = new List<integer>();
        datacount.add(tfcount);
        datacount.add(ffcount);
        datacount.add(sfcount);
        datacount.add(hncount);
         
        return datacount;
        
    }
    
     @AuraEnabled
    public static List<combineWrapper> combineChart_new(string type){
    
    Map<String, UCD_Account_DQ_Base_Field__mdt> baseFld = UCD_Account_DQ_Base_Field__mdt.getAll();
    List<UCD_Account_DQ_Base_Field__mdt> baseList = new List<UCD_Account_DQ_Base_Field__mdt>();
    for(String base : baseFld.keySet()){
        baseList.add(baseFld.get(base));
    }   
    
    Map<String, UCD_Account_DQ_Specific_Field__mdt> spFld = UCD_Account_DQ_Specific_Field__mdt.getAll();
    List<UCD_Account_DQ_Specific_Field__mdt> spList = new List<UCD_Account_DQ_Specific_Field__mdt>();
    for(String sp: spFld.keySet()){
        spList.add(spFld.get(sp));
    }   
        
        String columns = '';
        String condition = '';
        String accountName = 'UNCOVERED Account';
            
           
           for(UCD_Account_DQ_Base_Field__mdt md:baseList){
                      if(columns== ''){
                          columns= md.fieldAPIName__c;
                      }
                      else{
                          columns= columns+ ',' + md.fieldAPIName__c;
                      }              
            }

            for(UCD_Account_DQ_Specific_Field__mdt md:spList){
                           if(md.accountType__c == type){
                                  if(columns== ''){
                                      columns= md.fieldAPIName__c;
                                  }
                                  else{
                                      columns= columns+ ',' + md.fieldAPIName__c;
                                  }  
                           }              
            }
            
            if(type == 'ipa'){
                if(condition == ''){
                    condition = 'Core_Intel_Partner_Alliance_PartnerGroup__c = true ';
                }
                else{
                    condition = condition+ 'OR Core_Intel_Partner_Alliance_PartnerGroup__c = true ';
                }
                
            }
            if(type == 'a&e'){
                if(condition == ''){
                    condition = 'Core_B2B_Entitlement__c = true ';
                }
                else{
                    condition = condition+'OR Core_B2B_Entitlement__c = true ';
                }
            }
            if(type == 'psg'){
                if(condition == ''){
                    condition = 'Core_PSG_Account__c = true ';
                }
                else{
                    condition = condition+'OR Core_PSG_Account__c = true ';
                }
            }
            
            String query = 'select Id,Name, Core_Intel_Partner_Alliance_PartnerGroup__c,Core_B2B_Entitlement__c,Core_PSG_Account__c,';
                   query = query + columns + ' from Account where owner.Name !=:accountName AND ('+condition+')';
            system.debug('QQQQQQQQQQQ'+query);
            List<Account> fetchrec = Database.query(query); 
            system.debug('fetchrec--> '+fetchrec);
            Integer divscore = 0;
            Integer mdivscore = 0;
            Integer cdivscore = 0;
            
            for(UCD_Account_DQ_Base_Field__mdt md:baseList){ 
                     divscore= divscore+1;
                     cdivscore = cdivscore +1;                                           
            }
            
            for(UCD_Account_DQ_Specific_Field__mdt md:spList){ 
                     if(md.accountType__c == type){
                         divscore= divscore+1;
                         mdivscore= mdivscore+1;                        
                     }
            }
            Integer Finscore = 100/divscore;
            Integer mFinscore = 100/mdivscore;
            Integer cFinscore = 100/cdivscore;
            Integer Score=0;
            Integer coreScore = 0;
            Integer missScore = 0;
            String AccountType = '';
            List<combineWrapper> comwrapList = new List<combineWrapper>();
            
       for(Account acc:fetchrec){  
        Score = 0;
        coreScore = 0;
        missScore = 0;
       
       List<fieldData> MissingDataList = new List<fieldData>();
       List<fieldData> CoreDataList = new List<fieldData>();
        AccountType = '';
        combineWrapper comwrap = new combineWrapper();
                           
               Map<String, Object> fieldsToValue = acc.getPopulatedFieldsAsMap();              
                for(UCD_Account_DQ_Base_Field__mdt md:baseList){  ////// Base Field List
                        fieldData coreData = new fieldData();   
                           if(fieldsToValue.get(md.fieldAPIName__c) == null || fieldsToValue.get(md.fieldAPIName__c) == false){
                                   coreData.FieldName = md.MasterLabel;
                                   coreData.isfilled = false;
                           } 
                           else{
                               Score = Score+Finscore;
                               coreScore = coreScore+cFinscore;
                                   coreData.FieldName = md.MasterLabel;
                                   coreData.isfilled = true;
                           } 
                           coreDataList.add(coreData);
                
                }
                
                for(UCD_Account_DQ_Specific_Field__mdt md:spList){  /////// Specific Field List
                        if(md.accountType__c == type){    
                           fieldData MissingData = new fieldData();     
                           if(fieldsToValue.get(md.fieldAPIName__c) == null || fieldsToValue.get(md.fieldAPIName__c) == false){                             
                                   MissingData.FieldName = md.MasterLabel;
                                   MissingData.isfilled = false;
                           }
                           else{
                               Score = Score+Finscore;
                               missScore = missScore+mFinscore;
                               MissingData.FieldName = md.MasterLabel;
                               MissingData.isfilled = true;
                           } 
                           MissingDataList.add(MissingData);
                        }               
                }
                if(type=='ipa' && acc.Core_Intel_Partner_Alliance_PartnerGroup__c == true){
                    if(AccountType == ''){
                         AccountType = 'IPA';
                    }
                    else{
                         AccountType = AccountType + ',' + 'IPA';
                    } 
                }
                if(type == 'a&e' && acc.Core_B2B_Entitlement__c == true){
                    if(AccountType == ''){
                         AccountType = 'A&E';
                    }
                    else{
                         AccountType = AccountType + ',' + 'A&E';
                    }                
                }
                if(type == 'psg' && acc.Core_PSG_Account__c == true){
                    if(AccountType == ''){
                         AccountType = 'PSG';
                    }
                    else{
                         AccountType = AccountType + ',' + 'PSG';
                    } 
                }       
           
            
            comwrap.acc = acc;
            comwrap.score = Score;
            comwrap.coreScore = coreScore;
            comwrap.missScore = missScore;
            comwrap.MissingData = MissingDataList;
            comwrap.CoreData = coreDataList;
            comwrap.AccountType =AccountType;
            comwrapList.add(comwrap);          
        }
        system.debug('comwrapList'+comwrapList);
        return comwrapList;
    }
    
}