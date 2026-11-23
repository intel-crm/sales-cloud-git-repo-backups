/***************************************************************************************************************************************
Apex Class Name     : PRM_VXData_Report_Utility 
Version             : 1.0
Created Date        : Sept 2020
Function            : Utitlity class for PRM_VXData_Report_TriggerHandler.
Maximum Batch Size  : 
Modification Log    :
* Developer                         Date                           Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Dinesh                        7-Sept-2020                      US775505:Update Total Sales, Total Training.. Total Sales Units , reports with the partner role filter
* Srishty                       15-Sept-2020                     US775505: Created five fields for report purpose to show average value on the baisis of Account count and for Sales and Total Sales Unit 
Account and Sales Calculation Group combination count will be consider for average.
*Srishty                        22-Sept-2020                     DE93806: OPID recommendation/upgrade/Reports and Dashboards - Negative sales, training values comes form IAH are not considered while summing up 
for each values against the criteria
*Srishty                        24-Sept-2020                     US781640:Update caluclation of Sales to next tier (report) and Training credit to next tier(report) on the basis of OPID+Partner Role+Market type +Sales type combination.
* Ruchi                         18 July 2025                 Removed reference for Partner role(PRM_Partner_Role_Nm__c) on VX Data Table(PRM_Value_Exchange_Data__c). Added comment "IPA Refresh 2.0 - Removed partner role as part of TWC729-8087"
**************************************************************************************************************************************/
public without sharing class  PRM_VXData_Report_Utility {
    
    //this method will be called from handler class for updating report related calculation fields
    public static void trainingRecordsUpdate(List<PRM_Value_Exchange_Data__c> vxDataNewList)
    { 
        Set<Id> accountIds = new Set<Id>();//set of Account Id in trigger list
        Set<Id> opidSet =new Set<Id>();//set of OPID from trigger List
        for(PRM_Value_Exchange_Data__c vxData: vxDataNewList){
            accountIds.add(vxData.PRM_Account_Id__c);
            if(vxData.PRM_One_Partner_Id__c != null){
                opidSet.add(vxData.PRM_One_Partner_Id__c);
            }
            
        }
        set<string> locaccts=new set<String>();
        Map<String, Integer> countOfAccMap = new Map<String, Integer>();//map for AaccountId and Count of Account in VX Data obj
        Map<String,Integer> countOfAccSalesGroupMap =new Map<String,Integer>();//map for AccountId+SalesCalculation group with its count.
        Map<String,Integer> countSalesAndTrainingNextTierMap = new Map<String,Integer>();//map of count of VX data records based on combination OPID+PartnerRole+Market type+Sales calculation Group.If OPID is null then Account in combination.
        List<PRM_Value_Exchange_Data__c> vxDataOldList = new List<PRM_Value_Exchange_Data__c>();//List of VXData with all accountId part of trigger list
        for(PRM_Value_Exchange_Data__c v : [Select Id,Name,PRM_Account_Id__c,PRM_One_Partner_Id__c, /*PRM_Partner_Role_Nm__c, */ 
                                            PRM_Training_Credit_Points_Count_Nbr__c,PRM_Training_Credit_Points_Report_Nbr__c, 
                                            PRM_Training_credits_tier_report_Nbr__c, PRM_Training_credit_to_next_tier_per_nbr__c,
                                            PRM_Training_Credits_to_Next_Tier_Nbr__c,PRM_MP_Solutions_Count_Report_Nbr__c,
                                            PRM_MP_Solutions_Count_Nbr__c,PRM_Total_Achieved_Competency_Nbr__c,PRM_Country_Market_Type_Nm__c,
                                            PRM_Total_Achieved_Competency_Report_Nbr__c,PRM_Sales_Amount_Report_Nbr__c,PRM_Sales_Amount_Nbr__c,
                                            PRM_Sales_To_Next_Tier_Report_Nbr__c,PRM_Sales_To_Next_Tier_Nbr__c,
                                            PRM_Total_Sales_Out_Units_Report_Nbr__c,PRM_Total_Sales_Out_Units_Nbr__c,
                                            PRM_Percent_to_next_tier_Nbr__c,PRM_Sales_Calculation_Group_Txt__c,PRM_Processed_Date_Time_Dt__c,PRM_TimePeriod_Nm__c
                                            from PRM_Value_Exchange_Data__c 
                                            where PRM_Account_Id__c in :accountIds OR PRM_One_Partner_Id__c IN:opidSet order by PRM_One_Partner_Id__c]){ // IPA Refresh 2.0 - Removed partner role as part of TWC729-8087
                                                vxDataOldList.add(v);
                                                if(v.PRM_Account_Id__c != null){
                                                locaccts.add(v.PRM_Account_Id__c);
                                                }
                                                if(v.PRM_One_Partner_Id__c != null){
                                                locaccts.add(v.PRM_One_Partner_Id__c);
                                                }
                                                String keyForAccSalesGroup=v.PRM_Account_Id__c+v.PRM_Sales_Calculation_Group_Txt__c+v.PRM_TimePeriod_Nm__c;
                                                if(countOfAccSalesGroupMap.containsKey(keyForAccSalesGroup)){
                                                    Integer count = countOfAccSalesGroupMap.get(keyForAccSalesGroup)+1;
                                                    countOfAccSalesGroupMap.put(keyForAccSalesGroup,count);
                                                }else{
                                                    countOfAccSalesGroupMap.put(keyForAccSalesGroup,1);
                                                }
                                                if(countOfAccMap.containsKey(v.PRM_Account_Id__c)){
                                                    Integer value = countOfAccMap.get(v.PRM_Account_Id__c)+1;
                                                    countOfAccMap.put(v.PRM_Account_Id__c,value);
                                                }else{
                                                    countOfAccMap.put(v.PRM_Account_Id__c,1);
                                                }
                                                if(v.PRM_One_Partner_Id__c !=null){//this block will calculate combination counts for updating Sales to Next tier(report) and Training credit to Next tier(report) if OPID is not blank.
                                                    String keyOPIDToNextTier =v.PRM_One_Partner_Id__c/*+v.PRM_Partner_Role_Nm__c*/+v.PRM_Country_Market_Type_Nm__c; // IPA Refresh 2.0 - Removed partner role as part of TWC729-8087
                                                    if(countSalesAndTrainingNextTierMap.containsKey(keyOPIDToNextTier)){//this block updating map for Sales to next tier
                                                        Integer countforOPIDNextTier =countSalesAndTrainingNextTierMap.get(keyOPIDToNextTier)+1;
                                                        countSalesAndTrainingNextTierMap.put(keyOPIDToNextTier,countforOPIDNextTier);//updating map with key and its count in vx data records
                                                    }
                                                    else{
                                                        countSalesAndTrainingNextTierMap.put(keyOPIDToNextTier,1);//updating map with key and its count in vx data records
                                                    }
                                                    
                                                }
                                                else{//this block will calculate combination counts for updating Sales to Next tier(report) and Training credit to Next tier(report) if OPID is blank.
                                                    String keyNonOPIDToNextTier =v.PRM_Account_Id__c/*+v.PRM_Partner_Role_Nm__c*/+v.PRM_Country_Market_Type_Nm__c; //IPA Refresh 2.0 - Removed partner role as part of TWC729-8087
                                                    if(countSalesAndTrainingNextTierMap.containsKey(keyNonOPIDToNextTier)){//This block updating map for sales to next tier
                                                        Integer countforAccNextTier =countSalesAndTrainingNextTierMap.get(keyNonOPIDToNextTier)+1;
                                                        countSalesAndTrainingNextTierMap.put(keyNonOPIDToNextTier,countforAccNextTier);//updating map with key and its count in vx data records
                                                    }
                                                    else{
                                                        countSalesAndTrainingNextTierMap.put(keyNonOPIDToNextTier,1);//updating map with key and its count in vx data records
                                                    }
                                                }
                                                
                                                
                                            }//loop block ends here
                                            System.debug('@RRT countOfAccSalesGroupMap'+countOfAccSalesGroupMap);
                                            System.debug('@RRT countOfAccMap'+countOfAccMap);
                                            System.debug('@RRT countSalesAndTrainingNextTierMap'+countSalesAndTrainingNextTierMap);
             try {
                if (!vxDataOldList.isEmpty() && vxDataOldList.size() > 0) {
                    updateVXDataReportFieldsWrapper obj=new updateVXDataReportFieldsWrapper();
                    obj.vxDataOldList=vxDataOldList;
                    obj.countOfAccMap=countOfAccMap;
                    obj.countOfAccSalesGroupMap=countOfAccSalesGroupMap;
                    obj.countSalesAndTrainingNextTierMap=countSalesAndTrainingNextTierMap;
                    obj.locAccids=locaccts;
                    System.debug('@RRT obj'+obj);
                    updateVXDataReportFields(obj);//JB -- ATHR long parameters fix
                    /*updateVXDataReportFields(
                        vxDataOldList,
                        countOfAccMap,
                        countOfAccSalesGroupMap,
                        countSalesAndTrainingNextTierMap,
                        locaccts
                    );*/
                }
        
            } catch (Exception ex) {
            System.debug('Exceptions :'+ex.getMessage());
        } 
    }
    //US781640-This method will update the VX Data reporting field based on different criteria
    //private static void updateVXDataReportFields(List<PRM_Value_Exchange_Data__c> vxDataOldList,Map<String,Integer> countOfAccMap,Map<String,Integer> countOfAccSalesGroupMap,Map<String,Integer> countSalesAndTrainingNextTierMap,set<string> locAccids){
    //     List<PRM_Value_Exchange_Data__c> updateVXRcrds = new List<PRM_Value_Exchange_Data__c>();
    //     Boolean flagOne=false;
    //     Boolean flagTwo=false;
    //     Boolean flagThree=false;
    //     for(PRM_Value_Exchange_Data__c vxNew: vxDataOldList){
    //         String key=vxNew.PRM_Account_Id__c+vxNew.PRM_Sales_Calculation_Group_Txt__c+vxNew.PRM_TimePeriod_Nm__c;
    //         String KeyAccPartner =vxNew.PRM_Account_Id__c+vxNew.PRM_Partner_Role_Nm__c;
    //         String salesAndTrainingKey=vxNew.PRM_Account_Id__c+vxNew.PRM_Partner_Role_Nm__c+vxNew.PRM_Country_Market_Type_Nm__c;
            
    //         if(vxNew.PRM_One_Partner_Id__c !=null){
    //             salesAndTrainingKey=vxNew.PRM_One_Partner_Id__c+vxNew.PRM_Partner_Role_Nm__c+vxNew.PRM_Country_Market_Type_Nm__c;
    //         }
            
    //         if(!countOfAccMap.isEmpty() && countOfAccMap.containsKey(vxNew.PRM_Account_Id__c)){//updating field for caluclating average for reporting purpose on basis of AccountId count 
                
    //             vxNew.PRM_Training_Credit_Points_Report_Nbr__c = vxNew.PRM_Training_Credit_Points_Count_Nbr__c != null?vxNew.PRM_Training_Credit_Points_Count_Nbr__c/countOfAccMap.get(vxNew.PRM_Account_Id__c):0;//DE93806-Included negative value for the calculation
    //             vxNew.PRM_Total_Achieved_Competency_Report_Nbr__c = vxNew.PRM_Total_Achieved_Competency_Nbr__c != null?vxNew.PRM_Total_Achieved_Competency_Nbr__c/countOfAccMap.get(vxNew.PRM_Account_Id__c):0;//DE93806-Included negative value for the calculation
    //             vxNew.PRM_MP_Solutions_Count_Report_Nbr__c = vxNew.PRM_MP_Solutions_Count_Nbr__c !=null?vxNew.PRM_MP_Solutions_Count_Nbr__c/countOfAccMap.get(vxNew.PRM_Account_Id__c):0;//DE93806-Included negative value for the calculation
                
    //             flagOne=true;
            
    //        }
    //         if(!countOfAccSalesGroupMap.isEmpty() && countOfAccSalesGroupMap.containsKey(key)){//updating field for caluclating average for reporting purpose on basis of AccountId and SalesCalculationGroup count 
    //             vxNew.PRM_Sales_Amount_Report_Nbr__c = vxNew.PRM_Sales_Amount_Nbr__c !=null?vxNew.PRM_Sales_Amount_Nbr__c/countOfAccSalesGroupMap.get(key):0;//DE93806-Included negative value for the calculation
    //             vxNew.PRM_Total_Sales_Out_Units_Report_Nbr__c = vxNew.PRM_Total_Sales_Out_Units_Nbr__c !=null?vxNew.PRM_Total_Sales_Out_Units_Nbr__c/countOfAccSalesGroupMap.get(key):0;//DE93806-Included negative value for the calculation
    //             flagTwo=true;
    //         }
            
    //         if(!countSalesAndTrainingNextTierMap.isEmpty() && countSalesAndTrainingNextTierMap.containsKey(salesAndTrainingKey)){//updating fields on the basis of OPID/Acc+PartnerRole_Mkt+salestype count avg.
    //             vxNew.PRM_Sales_To_Next_Tier_Report_Nbr__c = vxNew.PRM_Sales_To_Next_Tier_Nbr__c !=null?vxNew.PRM_Sales_To_Next_Tier_Nbr__c/countSalesAndTrainingNextTierMap.get(salesAndTrainingKey):0;//DE93806-Included negative value for the calculation
    //             vxNew.PRM_Training_credits_tier_report_Nbr__c = vxNew.PRM_Training_Credits_to_Next_Tier_Nbr__c !=null?vxNew.PRM_Training_Credits_to_Next_Tier_Nbr__c/countSalesAndTrainingNextTierMap.get(salesAndTrainingKey):0;//DE93806-Included negative value for the calculation
                
    //             flagThree=true;
    //         }
            
            
            
    //         if(flagOne || flagTwo || flagThree){
    //             updateVXRcrds.add(vxNew);
    //         }

    //          }//loop ends here
    //     system.debug('---locAccids '+locAccids);
    //     if(locAccids!=null && locAccids.size()>0){
    //         list<AggregateResult> dataListTrainedSum = new list<AggregateResult >();
    //         map<string,decimal> creditmap=new map<string,decimal>();
    //         map<string,decimal> creditmapPrev=new map<string,decimal>();
    //         list<AggregateResult> dataListTrainedSumPrev = new list<AggregateResult >();
    //         dataListTrainedSumPrev = [SELECT max(PRM_Training_Credit_Points_Count_Nbr__c) totalTrained,PRM_Account_Id__c,PRM_One_Partner_Id__c   from PRM_Value_Exchange_Data__c WHERE (PRM_Account_Id__c in :locAccids or PRM_One_Partner_Id__c in:locAccids) and PRM_TimePeriod_Nm__c=:Label.PRM_Previous_Measurement_Period group by PRM_One_Partner_Id__c,PRM_Account_Id__c ];
    //         for(AggregateResult agresult: dataListTrainedSumPrev ){
    //             if((string)agresult.get('PRM_One_Partner_Id__c')!=null){
    //                 if(creditmapPrev.containskey((string)agresult.get('PRM_One_Partner_Id__c'))){
    //                     decimal  sumofcredit=creditmapPrev.get((string)agresult.get('PRM_One_Partner_Id__c'))+(Decimal)agresult.get('totalTrained');
    //                     creditmapPrev.put((string)agresult.get('PRM_One_Partner_Id__c'),sumofcredit);
    //                 }
    //                 else{
    //                     creditmapPrev.put((string)agresult.get('PRM_One_Partner_Id__c'),(Decimal)agresult.get('totalTrained'));
    //                 }
    //             }
    //             else if((string)agresult.get('PRM_Account_Id__c')!=null){
                    
    //                 if(creditmapPrev.containskey((string)agresult.get('PRM_Account_Id__c'))){
    //                     decimal  sumofcredit=creditmapPrev.get((string)agresult.get('PRM_Account_Id__c'))+(Decimal)agresult.get('totalTrained');
    //                     creditmapPrev.put((string)agresult.get('PRM_Account_Id__c'),sumofcredit);
    //                 }
    //                 else{
    //                     creditmapPrev.put((string)agresult.get('PRM_Account_Id__c'),(Decimal)agresult.get('totalTrained'));
    //                 }
    //             }
    //         }
    //         // if(creditmapPrev!=null){
    //             for(PRM_Value_Exchange_Data__c vx:updateVXRcrds){
    //                 if(vx.PRM_TimePeriod_Nm__c == Label.PRM_Previous_Measurement_Period){
    //                     if(creditmapPrev.containskey(vx.PRM_Account_Id__c)){
    //                         vx.PRM_Sum_of_Training_Credits__c=creditmapPrev.get(vx.PRM_Account_Id__c);
    //                     }
    //                     else if (creditmapPrev.containskey(vx.PRM_One_Partner_Id__c)){
    //                         vx.PRM_Sum_of_Training_Credits__c=creditmapPrev.get(vx.PRM_One_Partner_Id__c);
    //                     }
    //                 }
    //             }
                
    //         // }
    //         dataListTrainedSum = [SELECT max(PRM_Training_Credit_Points_Count_Nbr__c) totalTrained,PRM_Account_Id__c,PRM_One_Partner_Id__c   from PRM_Value_Exchange_Data__c WHERE (PRM_Account_Id__c in :locAccids or PRM_One_Partner_Id__c in:locAccids) and PRM_TimePeriod_Nm__c=:Label.PRM_Current_measurement_period group by PRM_One_Partner_Id__c,PRM_Account_Id__c ];
    //         system.debug('---dataListTrainedSum '+dataListTrainedSum );
    //         for(AggregateResult agresult: dataListTrainedSum ){
    //             if((string)agresult.get('PRM_One_Partner_Id__c')!=null)
    //             {
    //                 if(creditmap.containskey((string)agresult.get('PRM_One_Partner_Id__c'))){
    //                     decimal  sumofcredit=creditmap.get((string)agresult.get('PRM_One_Partner_Id__c'))+(Decimal)agresult.get('totalTrained');
    //                     creditmap.put((string)agresult.get('PRM_One_Partner_Id__c'),sumofcredit);
    //                 }
    //                 else{
    //                     creditmap.put((string)agresult.get('PRM_One_Partner_Id__c'),(Decimal)agresult.get('totalTrained'));
    //                 }
    //             }
    //             else if((string)agresult.get('PRM_Account_Id__c')!=null){
                    
    //                 if(creditmap.containskey((string)agresult.get('PRM_Account_Id__c'))){
    //                     decimal  sumofcredit=creditmap.get((string)agresult.get('PRM_Account_Id__c'))+(Decimal)agresult.get('totalTrained');
    //                     creditmap.put((string)agresult.get('PRM_Account_Id__c'),sumofcredit);
    //                 }
    //                 else{
    //                     creditmap.put((string)agresult.get('PRM_Account_Id__c'),(Decimal)agresult.get('totalTrained'));
    //                 }
    //             }
    //         }
    //         system.debug('---creditmap '+creditmap);
    //         if(creditmap!=null){
    //             for(PRM_Value_Exchange_Data__c vx:updateVXRcrds){
    //                 if(vx.PRM_TimePeriod_Nm__c == Label.PRM_Current_measurement_period){
    //                     if(creditmap.containskey(vx.PRM_Account_Id__c)){
    //                         vx.PRM_Sum_of_Training_Credits__c=creditmap.get(vx.PRM_Account_Id__c);
    //                     }
    //                     else if (creditmap.containskey(vx.PRM_One_Partner_Id__c)){
    //                         vx.PRM_Sum_of_Training_Credits__c=creditmap.get(vx.PRM_One_Partner_Id__c);
    //                     }
    //                 }
    //             }
                
    //         }
            
    //     }        
    //     if(Schema.sObjectType.PRM_Value_Exchange_Recommendation__c.isCreateable()){
    //         if(!updateVXRcrds.isEmpty()) {
    //             Database.update(updateVXRcrds);//updating VX records
    //         }
    //     }else {
    //             Core_Log_Entry.logEntryWithDetails('PRM_VXData_Report_Utility', 'IPA','updateVXDataReportFields', 'exception',System.label.PRM_Log_Entry_Error_Object_Level,System.label.PRM_Log_Entry_Error_Object_Level , ' ', '', ' ');
    //     }
    // 

    public class updateVXDataReportFieldsWrapper{
        public List<PRM_Value_Exchange_Data__c> vxDataOldList{get;set;}
        public Map<String,Integer> countOfAccMap{get;set;}
        public Map<String,Integer> countOfAccSalesGroupMap{get;set;}
        public Map<String,Integer> countSalesAndTrainingNextTierMap{get;set;}
        public set<string> locAccids{get;set;}
    }//JB

    private static void updateVXDataReportFields(updateVXDataReportFieldsWrapper att)
    {
        List<PRM_Value_Exchange_Data__c> updateVXRcrds = new List<PRM_Value_Exchange_Data__c>();
        Boolean flagOne=false;
        Boolean flagTwo=false;
        Boolean flagThree=false;
        for(PRM_Value_Exchange_Data__c vxNew: att.vxDataOldList){
            String key=vxNew.PRM_Account_Id__c+vxNew.PRM_Sales_Calculation_Group_Txt__c+vxNew.PRM_TimePeriod_Nm__c;
            //String KeyAccPartner =vxNew.PRM_Account_Id__c+vxNew.PRM_Partner_Role_Nm__c;
            String salesAndTrainingKey=vxNew.PRM_Account_Id__c/*+vxNew.PRM_Partner_Role_Nm__c*/+vxNew.PRM_Country_Market_Type_Nm__c; //IPA Refresh 2.0 - Removed partner role as part of TWC729-8087
            
            if(vxNew.PRM_One_Partner_Id__c !=null){
                salesAndTrainingKey=vxNew.PRM_One_Partner_Id__c/*+vxNew.PRM_Partner_Role_Nm__c*/+vxNew.PRM_Country_Market_Type_Nm__c; //IPA Refresh 2.0 - Removed partner role as part of TWC729-8087
            }
            System.debug('@RRT key'+key);
            System.debug('@RRT salesAndTrainingKey'+salesAndTrainingKey);
            System.debug('@RRT att.countOfAccMap'+att.countOfAccMap.get(vxNew.PRM_Account_Id__c));
            System.debug('@RRT countOfAccSalesGroupMap'+att.countOfAccSalesGroupMap.get(key));
            System.debug('@RRT countSalesAndTrainingNextTierMap'+att.countSalesAndTrainingNextTierMap.get(salesAndTrainingKey));
            if(!att.countOfAccMap.isEmpty() && att.countOfAccMap.containsKey(vxNew.PRM_Account_Id__c)){//updating field for caluclating average for reporting purpose on basis of AccountId count 
                
                vxNew.PRM_Training_Credit_Points_Report_Nbr__c = vxNew.PRM_Training_Credit_Points_Count_Nbr__c != null?vxNew.PRM_Training_Credit_Points_Count_Nbr__c/att.countOfAccMap.get(vxNew.PRM_Account_Id__c):0;//DE93806-Included negative value for the calculation
                vxNew.PRM_Total_Achieved_Competency_Report_Nbr__c = vxNew.PRM_Total_Achieved_Competency_Nbr__c != null?vxNew.PRM_Total_Achieved_Competency_Nbr__c/att.countOfAccMap.get(vxNew.PRM_Account_Id__c):0;//DE93806-Included negative value for the calculation
                vxNew.PRM_MP_Solutions_Count_Report_Nbr__c = vxNew.PRM_MP_Solutions_Count_Nbr__c !=null?vxNew.PRM_MP_Solutions_Count_Nbr__c/att.countOfAccMap.get(vxNew.PRM_Account_Id__c):0;//DE93806-Included negative value for the calculation
                
                flagOne=true;
            
           }
            if(!att.countOfAccSalesGroupMap.isEmpty() && att.countOfAccSalesGroupMap.containsKey(key)){//updating field for caluclating average for reporting purpose on basis of AccountId and SalesCalculationGroup count 
                vxNew.PRM_Sales_Amount_Report_Nbr__c = vxNew.PRM_Sales_Amount_Nbr__c !=null?vxNew.PRM_Sales_Amount_Nbr__c/att.countOfAccSalesGroupMap.get(key):0;//DE93806-Included negative value for the calculation
                vxNew.PRM_Total_Sales_Out_Units_Report_Nbr__c = vxNew.PRM_Total_Sales_Out_Units_Nbr__c !=null?vxNew.PRM_Total_Sales_Out_Units_Nbr__c/att.countOfAccSalesGroupMap.get(key):0;//DE93806-Included negative value for the calculation
                flagTwo=true;
            }
            
            if(!att.countSalesAndTrainingNextTierMap.isEmpty() && att.countSalesAndTrainingNextTierMap.containsKey(salesAndTrainingKey)){//updating fields on the basis of OPID/Acc+PartnerRole_Mkt+salestype count avg.
                vxNew.PRM_Sales_To_Next_Tier_Report_Nbr__c = vxNew.PRM_Sales_To_Next_Tier_Nbr__c !=null?vxNew.PRM_Sales_To_Next_Tier_Nbr__c/att.countSalesAndTrainingNextTierMap.get(salesAndTrainingKey):0;//DE93806-Included negative value for the calculation
                vxNew.PRM_Training_credits_tier_report_Nbr__c = vxNew.PRM_Training_Credits_to_Next_Tier_Nbr__c !=null?vxNew.PRM_Training_Credits_to_Next_Tier_Nbr__c/att.countSalesAndTrainingNextTierMap.get(salesAndTrainingKey):0;//DE93806-Included negative value for the calculation
                
                flagThree=true;
            }
            
            
            System.debug('@RRT flagOne'+flagOne);
            System.debug('@RRT flagTwo'+flagTwo);
            System.debug('@RRT flagThree'+flagThree);
            System.debug('@RRT vxNew.PRM_Training_Credit_Points_Report_Nbr__c '+vxNew.PRM_Training_Credit_Points_Report_Nbr__c );
            System.debug('@RRT vxNew.PRM_Total_Achieved_Competency_Report_Nbr__c'+vxNew.PRM_Total_Achieved_Competency_Report_Nbr__c);
            System.debug('@RRT vxNew.PRM_MP_Solutions_Count_Report_Nbr__c'+vxNew.PRM_MP_Solutions_Count_Report_Nbr__c);
            System.debug('@RRT vxNew.PRM_Sales_Amount_Report_Nbr__c'+vxNew.PRM_Sales_Amount_Report_Nbr__c);
            System.debug('@RRT vxNew.PRM_Total_Sales_Out_Units_Report_Nbr__c'+vxNew.PRM_Total_Sales_Out_Units_Report_Nbr__c);
            System.debug('@RRT vxNew.PRM_Sales_To_Next_Tier_Report_Nbr__c'+vxNew.PRM_Sales_To_Next_Tier_Report_Nbr__c);
            System.debug('@RRT vxNew.PRM_Training_credits_tier_report_Nbr__c'+vxNew.PRM_Training_credits_tier_report_Nbr__c);
            if(flagOne || flagTwo || flagThree){
                updateVXRcrds.add(vxNew);
            }
    
             }//loop ends here
        //system.debug('---att.locAccids '+att.locAccids);
        if(att.locAccids!=null && att.locAccids.size()>0){
            list<AggregateResult> dataListTrainedSum = new list<AggregateResult >();
            map<string,decimal> creditmap=new map<string,decimal>();
            map<string,decimal> creditmapPrev=new map<string,decimal>();
            list<AggregateResult> dataListTrainedSumPrev = new list<AggregateResult >();
            dataListTrainedSumPrev = [SELECT max(PRM_Training_Credit_Points_Count_Nbr__c) totalTrained,PRM_Account_Id__c,PRM_One_Partner_Id__c   from PRM_Value_Exchange_Data__c WHERE (PRM_Account_Id__c in :att.locAccids or PRM_One_Partner_Id__c in:att.locAccids) and PRM_TimePeriod_Nm__c=:Label.PRM_Previous_Measurement_Period group by PRM_One_Partner_Id__c,PRM_Account_Id__c ];
            for(AggregateResult agresult: dataListTrainedSumPrev ){
                if((string)agresult.get('PRM_One_Partner_Id__c')!=null){
                    if(creditmapPrev.containskey((string)agresult.get('PRM_One_Partner_Id__c'))){
                        decimal  sumofcredit=creditmapPrev.get((string)agresult.get('PRM_One_Partner_Id__c'))+(Decimal)agresult.get('totalTrained');
                        creditmapPrev.put((string)agresult.get('PRM_One_Partner_Id__c'),sumofcredit);
                    }
                    else{
                        creditmapPrev.put((string)agresult.get('PRM_One_Partner_Id__c'),(Decimal)agresult.get('totalTrained'));
                    }
                }
                else if((string)agresult.get('PRM_Account_Id__c')!=null){
                    
                    if(creditmapPrev.containskey((string)agresult.get('PRM_Account_Id__c'))){
                        decimal  sumofcredit=creditmapPrev.get((string)agresult.get('PRM_Account_Id__c'))+(Decimal)agresult.get('totalTrained');
                        creditmapPrev.put((string)agresult.get('PRM_Account_Id__c'),sumofcredit);
                    }
                    else{
                        creditmapPrev.put((string)agresult.get('PRM_Account_Id__c'),(Decimal)agresult.get('totalTrained'));
                    }
                }
            }
            // if(creditmapPrev!=null){
                for(PRM_Value_Exchange_Data__c vx:updateVXRcrds){
                    if(vx.PRM_TimePeriod_Nm__c == Label.PRM_Previous_Measurement_Period){
                        if(creditmapPrev.containskey(vx.PRM_Account_Id__c)){
                            vx.PRM_Sum_of_Training_Credits__c=creditmapPrev.get(vx.PRM_Account_Id__c);
                        }
                        else if (creditmapPrev.containskey(vx.PRM_One_Partner_Id__c)){
                            vx.PRM_Sum_of_Training_Credits__c=creditmapPrev.get(vx.PRM_One_Partner_Id__c);
                        }
                    }
                }
                
            // }
            dataListTrainedSum = [SELECT max(PRM_Training_Credit_Points_Count_Nbr__c) totalTrained,PRM_Account_Id__c,PRM_One_Partner_Id__c   from PRM_Value_Exchange_Data__c WHERE (PRM_Account_Id__c in :att.locAccids or PRM_One_Partner_Id__c in:att.locAccids) and PRM_TimePeriod_Nm__c=:Label.PRM_Current_measurement_period group by PRM_One_Partner_Id__c,PRM_Account_Id__c ];
            //system.debug('---dataListTrainedSum '+dataListTrainedSum );
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
            //system.debug('---creditmap '+creditmap);
            if(creditmap!=null){
                for(PRM_Value_Exchange_Data__c vx:updateVXRcrds){
                    if(vx.PRM_TimePeriod_Nm__c == Label.PRM_Current_measurement_period){
                        if(creditmap.containskey(vx.PRM_Account_Id__c)){
                            vx.PRM_Sum_of_Training_Credits__c=creditmap.get(vx.PRM_Account_Id__c);
                        }
                        else if (creditmap.containskey(vx.PRM_One_Partner_Id__c)){
                            vx.PRM_Sum_of_Training_Credits__c=creditmap.get(vx.PRM_One_Partner_Id__c);
                        }
                    }
                }
                
            }
            
        }       
        if(Schema.sObjectType.PRM_Value_Exchange_Recommendation__c.isCreateable()){
            if(!updateVXRcrds.isEmpty()) {
                List<Database.SaveResult> result = Database.update(updateVXRcrds);//updating VX records
                for(Database.SaveResult sr : result) {
                    if(!sr.isSuccess()) {
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('RRTError -->'+sr.getErrors()+'Id -->'+sr.getId());
                        }
                    }
                }
            }
        }else {
                Core_Log_Entry.logEntryWithDetails('PRM_VXData_Report_Utility', 'IPA','updateVXDataReportFields', 'exception',System.label.PRM_Log_Entry_Error_Object_Level,System.label.PRM_Log_Entry_Error_Object_Level , ' ', '', ' ');
        }
    }
       public static void updateMarketType(List<PRM_Value_Exchange_Data__c> vxDataList, Map<Id,PRM_Value_Exchange_Data__c> vxDataOldMap){
       // List<PRM_Value_Exchange_Data__c> vxDataList = new List<PRM_Value_Exchange_Data__c>();
       if (!vxDataList.isEmpty()){
            for(PRM_Value_Exchange_Data__c vxNew: vxDataList){
                if(vxNew.PRM_Account_Id__r != null &&
            vxNew.PRM_Account_Id__r.Core_IPA_Partner_Role__c != null){
                if((vxDataOldMap == null ||  (vxDataOldMap != null && vxDataOldMap.get(vxNew.Id).PRM_Account_Id__r.Core_IPA_Partner_Role__c !=  vxNew.PRM_Account_Id__r.Core_IPA_Partner_Role__c )) &&
                  (!(vxNew.PRM_Account_Id__r.Core_IPA_Partner_Role__c.contains('Seller')))  && (!(vxNew.PRM_Account_Id__r.Core_IPA_Partner_Role__c.contains('Original Equipment Manufacturer (OEM)')))) { ////IPA Refresh 2.0 - Removed partner role as part of TWC729-8087
                    vxNew.PRM_Country_Market_Type_Nm__c = 'NA';
                }
            }
            }
        }
    }
    public static void shareRecordWithPublicGroup(List<PRM_Value_Exchange_Data__c> vxDataList){
        try{
            List<PRM_Value_Exchange_Data__Share> vxDataShareRecList = new List<PRM_Value_Exchange_Data__Share>();
            Group grp = [
                SELECT Id
                FROM Group
                WHERE DeveloperName = 'PMP_All_Partner_Users'
                LIMIT 1
            ];
            if(vxDataList != null && vxDataList.size() > 0 &&  !vxDataList.isEmpty()){
                for(PRM_Value_Exchange_Data__c vxData :vxDataList){
                    PRM_Value_Exchange_Data__Share shareRec = new PRM_Value_Exchange_Data__Share();
                    shareRec.ParentId = vxData.Id;
                    shareRec.UserOrGroupId = grp.Id;
                    shareRec.AccessLevel = 'Edit'; // Read or Edit
                    shareRec.RowCause = Schema.PRM_Value_Exchange_Data__Share.RowCause.Manual;
                    vxDataShareRecList.add(shareRec);
                    
                }
            }
            system.debug('vxDataShareRecList-->'+vxDataShareRecList);
            if(vxDataShareRecList != null && vxDataShareRecList.size() > 0 &&  !vxDataShareRecList.isEmpty()){
                insert vxDataShareRecList;
            }
        }
        catch(exception e){
            Core_Log_Entry__c excepLog = new Core_Log_Entry__c(Core_Message__c = e.getMessage(), Core_Origin__c = 'PRM_VXData_Report_Utility', Core_Project__c = 'PRM_VXData_Report_Utility' , Core_Details__c = 'Getting exception for VX Data record sharing', Core_Severity__c = 'info', Core_When__c = System.Now());
        }
    }
}