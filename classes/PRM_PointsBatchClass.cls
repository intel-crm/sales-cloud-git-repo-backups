public  without sharing class PRM_PointsBatchClass implements Database.Batchable<Sobject>{
    
    public static Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('select id, PRM_Account_Id_txt__c, PRM_Available_Points_nbr__c, PRM_Change_Ts_txt__c, PRM_End_Date__c, PRM_Expired_Points_nbr__c, PRM_hash_id_nbr__c, PRM_One_Partner_ID_txt__c, PRM_Points_Earned_nbr__c, PRM_Points_Exp_In_Current_Quarter_nbr__c, PRM_Points_Redeemed_nbr__c, PRM_Process_Date_Time__c, PRM_record_level_hash_Id_nbr__c, PRM_Start_Date__c from PRM_Point_Data_Stage__c where PRM_Process_Date_Time__c =null');
    }
    
    public static void execute(Database.BatchableContext bc, List<Sobject> sop){
        System.debug('Soap -->'+sop);
        List<PRM_Points_Data__c> pointsLst = new List<PRM_Points_Data__c>();
        Map<id, List<PRM_Points_Data__c>> acctIdPtDataMap =new Map<id,List<PRM_Points_Data__c>>();               
        Set<Id> accoundId = new Set<Id>();        
        List<PRM_Point_Data_Stage__c> pointsStageLst = new List<PRM_Point_Data_Stage__c>();
        Map<Id, Id> accountIdOPID = new Map<Id, Id>();
        // create map of Id(AccountId/OPID)->recordId)
        //Map<id, Set<PRM_Point_Data_Stage__c>> pointsStageSetMap = new Map<id, Set<PRM_Point_Data_Stage__c>>();
        for(Sobject sob : sop){
            PRM_Point_Data_Stage__c pds  = (PRM_Point_Data_Stage__c)sob; // cast from sobject to object
            accountIdOPID.put(pds.PRM_Account_Id_txt__c,pds.PRM_One_Partner_ID_txt__c);
            //accoundId.add(pds.PRM_Account_Id_txt__c); // to get the data from points datat table if any record present for account which is tagged to OPID                      
        }
        
        for(PRM_Points_Data__c pt : [select id,PRM_Account_Id__c,PRM_Change_Date_Time_Dt__c, PRM_End_Date_Dt__c, PRM_One_Partner_Id__c, PRM_Points_ext_id__c,
                                     PRM_Start_Date_Dt__c, PRM_Total_Points_Available_Nbr__c, PRM_Total_Points_Due_to_Expire_Nbr__c, PRM_Total_Points_Earned_Nbr__c, 
                                     PRM_Total_Points_Expired_Nbr__c, PRM_Total_Points_Redeemed_Nbr__c,PRM_Inactive_Indicator__c from PRM_Points_Data__c 
                                     where PRM_Account_Id__c in :accountIdOPID.keySet() and PRM_One_Partner_Id__c=null and PRM_Inactive_Indicator__c=false])
        {
            if(acctIdPtDataMap!=null && !acctIdPtDataMap.isEmpty() && acctIdPtDataMap.containsKey(pt.PRM_Account_Id__c)){
                List<PRM_Points_Data__c> ptLst = acctIdPtDataMap.get(pt.PRM_Account_Id__c);
                if(!ptLst.contains(pt)){ptLst.add(pt);}
                acctIdPtDataMap.put(pt.PRM_Account_Id__c, ptLst);
            }else{
                acctIdPtDataMap.put(pt.PRM_Account_Id__c, new List<PRM_Points_Data__c>{pt});    
            }
            
        }        
        
        Map<PRM_Point_Data_Stage__c,List<PRM_Points_Data__c>> stageDataPtDataMap = new Map<PRM_Point_Data_Stage__c,List<PRM_Points_Data__c>>();
        
        for(Sobject sob : sop){
            PRM_Point_Data_Stage__c pds  = (PRM_Point_Data_Stage__c)sob; // cast from sobject to object            
            // adding to list for updated
            if(!pointsStageLst.contains(pds)){
                pds.PRM_Process_Date_Time__c =  System.now();
                pointsStageLst.add(pds);
            }
            
            if(acctIdPtDataMap!=null && pds.PRM_One_Partner_ID_txt__c!=null && acctIdPtDataMap.containsKey(pds.PRM_Account_Id_txt__c)){
                stageDataPtDataMap.put(pds,acctIdPtDataMap.get(pds.PRM_Account_Id_txt__c));
            }
            else{
                PRM_Points_Data__c pt = new PRM_Points_Data__c();
                pt.PRM_Account_Id__c =pds.PRM_Account_Id_txt__c;
                pt.PRM_Change_Date_Time_Dt__c= null;            
                pt.PRM_End_Date_Dt__c =null;            
                pt.PRM_One_Partner_Id__c=pds.PRM_One_Partner_ID_txt__c;
                pt.PRM_Start_Date_Dt__c=null;
                pt.PRM_Total_Points_Available_Nbr__c=pds.PRM_Available_Points_nbr__c!=null?pds.PRM_Available_Points_nbr__c:0;
                pt.PRM_Total_Points_Due_to_Expire_Nbr__c=0;
                pt.PRM_Total_Points_Earned_Nbr__c=pds.PRM_Points_Earned_nbr__c!=null?pds.PRM_Points_Earned_nbr__c:0;
                pt.PRM_Total_Points_Expired_Nbr__c=pds.PRM_Points_Exp_In_Current_Quarter_nbr__c!=null?pds.PRM_Points_Exp_In_Current_Quarter_nbr__c:0;
                pt.PRM_Total_Points_Redeemed_Nbr__c=pds.PRM_Points_Redeemed_nbr__c!=null?pds.PRM_Points_Redeemed_nbr__c:0;
                if(!pointsLst.contains(pt)){
                    pointsLst.add(pt);
                }
            }
        }
        
        System.debug('stageDataPtDataMap -->'+stageDataPtDataMap);
        
        for(PRM_Point_Data_Stage__c pds : stageDataPtDataMap.keySet()){
            PRM_Points_Data__c pt = new PRM_Points_Data__c();
            pt.PRM_Account_Id__c =pds.PRM_Account_Id_txt__c;
            pt.PRM_Change_Date_Time_Dt__c= null;            
            pt.PRM_End_Date_Dt__c =null;            
            pt.PRM_One_Partner_Id__c=pds.PRM_One_Partner_ID_txt__c;
            pt.PRM_Start_Date_Dt__c=null;
            pt.PRM_Total_Points_Available_Nbr__c=pds.PRM_Available_Points_nbr__c!=null?pds.PRM_Available_Points_nbr__c:0;
            pt.PRM_Total_Points_Due_to_Expire_Nbr__c=pds.PRM_Points_Exp_In_Current_Quarter_nbr__c!=null?pds.PRM_Points_Exp_In_Current_Quarter_nbr__c:0;
            pt.PRM_Total_Points_Earned_Nbr__c= pds.PRM_Points_Earned_nbr__c!=null?pds.PRM_Points_Earned_nbr__c:0;
            pt.PRM_Total_Points_Expired_Nbr__c=pds.PRM_Expired_Points_nbr__c!=null?pds.PRM_Expired_Points_nbr__c:0;
            pt.PRM_Total_Points_Redeemed_Nbr__c=pds.PRM_Points_Redeemed_nbr__c!=null?pds.PRM_Points_Redeemed_nbr__c:0;
                
            for(PRM_Points_Data__c pd : stageDataPtDataMap.get(pds)){        
                /*System.debug(' -->'+pt.PRM_Total_Points_Available_Nbr__c+' -->'+pd.PRM_Total_Points_Available_Nbr__c);
                pt.PRM_Total_Points_Available_Nbr__c=pt.PRM_Total_Points_Available_Nbr__c!=null?pt.PRM_Total_Points_Available_Nbr__c:0+pd.PRM_Total_Points_Available_Nbr__c!=null?pd.PRM_Total_Points_Available_Nbr__c:0;
                pt.PRM_Total_Points_Due_to_Expire_Nbr__c=pt.PRM_Total_Points_Due_to_Expire_Nbr__c!=null?pt.PRM_Total_Points_Due_to_Expire_Nbr__c:0+pd.PRM_Total_Points_Due_to_Expire_Nbr__c!=null?pd.PRM_Total_Points_Due_to_Expire_Nbr__c:0;
                pt.PRM_Total_Points_Earned_Nbr__c=pt.PRM_Total_Points_Earned_Nbr__c!=null?pt.PRM_Total_Points_Earned_Nbr__c:0+pd.PRM_Total_Points_Earned_Nbr__c!=null?pd.PRM_Total_Points_Earned_Nbr__c:0;
                pt.PRM_Total_Points_Expired_Nbr__c=pt.PRM_Total_Points_Expired_Nbr__c!=null?pt.PRM_Total_Points_Expired_Nbr__c:0+pd.PRM_Total_Points_Expired_Nbr__c!=null?pd.PRM_Total_Points_Expired_Nbr__c:0;
                pt.PRM_Total_Points_Redeemed_Nbr__c=pt.PRM_Total_Points_Redeemed_Nbr__c!=null?pt.PRM_Total_Points_Redeemed_Nbr__c:0+pd.PRM_Total_Points_Redeemed_Nbr__c!=null?pd.PRM_Total_Points_Redeemed_Nbr__c:0;                */
                pd.PRM_Inactive_Indicator__c=true;
                if(!pointsLst.contains(pd)){
                    pointsLst.add(pd);
                }
            }
            if(!pointsLst.contains(pt)){
                pointsLst.add(pt);
            }
        }
        
        // get the data from PRM_Points_Data__c table where OPID is not assigned for the account where inactive ind is faslse
        System.debug('pointsStageLst -->'+pointsStageLst );
        System.debug('pointsLst -->'+pointsLst );
        
        if(pointsLst!=null && !pointsLst.isEmpty()){
            //Database.insert(pointsLst[0]);
            Database.UpsertResult [] srList =  Database.upsert(pointsLst,false);
            for(Database.UpsertResult sr : srList){
                if(!sr.isSuccess()){
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('Error -->'+err.getMessage()+'Id -->'+sr.getId());
                    }
                }
            }
        }
        
        if(pointsStageLst!=null && !pointsStageLst.isEmpty()){
            Database.SaveResult[] srList =  Database.update(pointsStageLst);
            for(Database.SaveResult sr : srList){
                if(!sr.isSuccess()){
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('Error -->'+err.getMessage()+'Id -->'+sr.getId());
                    }
                }
            }
        }
    }
    
    public static void finish(Database.BatchableContext bc){
        System.debug('Batch 1 Finished Execution');
    }
    
}