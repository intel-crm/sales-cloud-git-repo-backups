Public class PRM_ValueExchangeUpdateBatch implements Database.Batchable<sObject> {
    
    public String strTimePeriod;
    
    public PRM_ValueExchangeUpdateBatch(String timePeriod) {
        strTimePeriod = timePeriod;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {      
        
        String query = 'Select Id, PRM_Account_Id__c,PRM_One_Partner_Id__c,PRM_Training_Credit_Points_Count_Nbr__c,PRM_Sum_of_Training_Credits__c from PRM_Value_Exchange_Data__c where PRM_TimePeriod_Nm__c=:strTimePeriod';
        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC,List<PRM_Value_Exchange_Data__c> liftOfValueExchange) {
        set<string> locaccts=new set<String>();       
        List<PRM_Value_Exchange_Data__c> updateVXRcrds = new List<PRM_Value_Exchange_Data__c>();
        
        for(PRM_Value_Exchange_Data__c v :liftOfValueExchange)
        {
            locaccts.add(v.PRM_Account_Id__c);
            locaccts.add(v.PRM_One_Partner_Id__c);
            
        }
        if(locaccts!=null && locaccts.size()>0){
            map<string,decimal> creditmap=getcreditMap(locaccts, strTimePeriod);
            
            if(creditmap!=null){
                for(PRM_Value_Exchange_Data__c vx:liftOfValueExchange){
                    if(creditmap.containskey(vx.PRM_One_Partner_Id__c)){
                        vx.PRM_Sum_of_Training_Credits__c=creditmap.get(vx.PRM_One_Partner_Id__c);
                    }
                    else if (creditmap.containskey(vx.PRM_Account_Id__c)){
                        vx.PRM_Sum_of_Training_Credits__c=creditmap.get(vx.PRM_Account_Id__c);
                    }
                    updateVXRcrds.add(vx);
                }
            }
        }
            if(!updateVXRcrds.isEmpty()){
                Database.update(updateVXRcrds,false);//updating VX records
            }
        }
        public static map<string,decimal> getcreditMap(set<string> locaccts, String strTimePeriod){
            list<AggregateResult> dataListTrainedSum = [SELECT max(PRM_Training_Credit_Points_Count_Nbr__c) totalTrained,PRM_Account_Id__c,PRM_One_Partner_Id__c   
                                  from PRM_Value_Exchange_Data__c WHERE (PRM_Account_Id__c in :locaccts or PRM_One_Partner_Id__c in:locaccts) and PRM_TimePeriod_Nm__c=:strTimePeriod group by PRM_One_Partner_Id__c,PRM_Account_Id__c ];
            map<string,decimal> creditmap=new map<string,decimal>();
            for(AggregateResult agresult: dataListTrainedSum ){
                if((string)agresult.get('PRM_One_Partner_Id__c')!=null)
                {
                    if(creditmap.containskey((string)agresult.get('PRM_One_Partner_Id__c'))){
                        decimal  sumofcredit=creditmap.get((string)agresult.get('PRM_One_Partner_Id__c'))+(Decimal)agresult.get('totalTrained');
                        creditmap.put((string)agresult.get('PRM_One_Partner_Id__c'),sumofcredit);
                    }
                    else{
                        creditmap.put((string)agresult.get('PRM_One_Partner_Id__c'),(Decimal)agresult.get('totalTrained'));
                    }
                }
                else if((string)agresult.get('PRM_Account_Id__c')!=null){
                    
                    if(creditmap.containskey((string)agresult.get('PRM_Account_Id__c'))){
                        decimal  sumofcredit=creditmap.get((string)agresult.get('PRM_Account_Id__c'))+(Decimal)agresult.get('totalTrained');
                        creditmap.put((string)agresult.get('PRM_Account_Id__c'),sumofcredit);
                    }
                    else{
                        creditmap.put((string)agresult.get('PRM_Account_Id__c'),(Decimal)agresult.get('totalTrained'));
                    }
                }
            }
            return creditmap;
        }
        public void finish(Database.BatchableContext BC) {
            
        }
    }