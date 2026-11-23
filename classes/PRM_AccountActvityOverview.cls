public without sharing class PRM_AccountActvityOverview {
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_INFO     = 'info';
    public static final String LOG_ENTRY_ORIGIN   = 'PRM_OPID_OnDemandsyncRequest';
    public static final String LOG_ENTRY_PROJECT  = 'On Demand Sync';
    public static final String LOG_ENTRY_SCOPE    = 'PRM_OPID_OnDemandsyncRequest';
    public static final String LOG_ENTRY_SEVERITY = 'Medium';
    
    @AuraEnabled
    Public static responseWrapper displayPointsData(Id accID){
        responseWrapper rs = new responseWrapper();
        try{        
        Account acc = [select Id,Core_IPA_One_Partner_Id__c, RecordType.DeveloperName from Account where Id =:accID];
        //String vxQuery;
        Decimal totalTrainingCurrent, totalTrainingPrev;//sumOfTrainingAmt,oldTrainingAmt,totalAmt;
        //Decimal sumOfTrainingAmtpre,oldTrainingAmtpre,totalAmtpre;
        List<AggregateResult> dataList = new List<AggregateResult>();
        List<AggregateResult> trainingValdataList = new List<AggregateResult>();
        List<AggregateResult> dataListPrev = new List<AggregateResult>();
        List<AggregateResult> trainingValdataListprev = new List<AggregateResult>();
        List<AggregateResult> trainingCurrentList = new List<AggregateResult>();
        List<AggregateResult> dataListTrained = new List<AggregateResult>();
        List<AggregateResult> dataListTrainedSum = new List<AggregateResult>();
        Set<Id> uniqueRecIdsSet = new Set<Id>();
        map<string,decimal> trainingOldMap=new map<string,decimal>();
        //map<string,decimal> trainingNewMap=new map<string,decimal>();
        Map<Decimal, String> vxValuesMap = new Map<Decimal, String>();
        //Map<Id, Decimal> trainingValuesMap = new Map<Id, Decimal>();
        Map<Id, Map<Decimal, String>> vxMap = new Map<Id, Map<Decimal, String>>();
        //Map<String, decimal> trainingCreditMap = new Map<String,decimal>();
        //List<AggregateResult> totalApprovedOfferingList = new List<AggregateResult>();//IPA2.0 TWC727-3228
      //List<AggregateResult> totalApprovedSolutionsList = new List<AggregateResult>();//IPA2.0 TWC727-3228
        Map<ID,List<String>> accSalesCombination = new Map<ID,List<String>>();
        map<id,Decimal> trainingCurMap=new map<id,Decimal>();
        map<id,Decimal> trainingPrevMap=new map<id,Decimal>();
        //Boolean isPublishedStorefront;//IPA2.0 TWC727-3228
        String whereClause;
        //oldTrainingAmt = 0;
        //oldTrainingAmtpre = 0;
    Decimal sumCurrent=0,sumPrevious=0;
    
        if(acc.RecordType.DeveloperName=='Core_Partner_Account_Group'){
            whereClause = 'where PRM_One_Partner_Id__c =:accID group by PRM_One_Partner_Id__c';
            for(PRM_Value_Exchange_Data__c vxData: [SELECT Id,PRM_Account_Id__c,PRM_TimePeriod_Nm__c,PRM_Training_Credit_Points_Count_Nbr__c, PRM_Sales_Amount_Nbr__c,PRM_Sales_Calculation_Group_Txt__c/*,PRM_To_Dt__c,PRM_From_Dt__c,PRM_Training_Credit_Points_Report_Nbr__c ,PRM_Number_Of_Employees_Nbr__c*/ from PRM_Value_Exchange_Data__c WHERE PRM_One_Partner_Id__c =:accID order by PRM_Training_Credit_Points_Count_Nbr__c ]){//ATHR Fix - TWC729-9556
                
                trainingOldMap.put(vxData.PRM_TimePeriod_Nm__c+','+vxData.PRM_Account_Id__c,vxData.PRM_Training_Credit_Points_Count_Nbr__c);
                String str = vxData.PRM_TimePeriod_Nm__c;
                //string accIdandTimePriod = vxData.PRM_TimePeriod_Nm__c+vxData.PRM_Account_Id__c;
                if(!vxMap.containsKey(vxData.PRM_Account_Id__c)) {
                    
                    if(vxData.PRM_Sales_Amount_Nbr__c !=null){
                        List<string> salesGrp = new List<string>();
                        salesGrp.add(vxData.PRM_Sales_Amount_Nbr__c+vxData.PRM_Sales_Calculation_Group_Txt__c+vxData.PRM_TimePeriod_Nm__c);
                        vxValuesMap.put(vxData.PRM_Sales_Amount_Nbr__c, vxData.PRM_Sales_Calculation_Group_Txt__c);
                        vxMap.put(vxData.PRM_Account_Id__c, vxValuesMap);
                        accSalesCombination.put(vxData.PRM_Account_Id__c,salesGrp);
                        uniqueRecIdsSet.add(vxData.Id);
                    }
                    
                }
                
                else{
                    //get the map values for corresponding account , and check if the same combination exists in the list <string> , if yes , then dont add for cacl
                    List<String> comb = accSalesCombination.get(vxData.PRM_Account_Id__c);
                    string combNew = vxData.PRM_Sales_Amount_Nbr__c+vxData.PRM_Sales_Calculation_Group_Txt__c+vxData.PRM_TimePeriod_Nm__c;
                    if((!comb.contains(combNew)) && vxData.PRM_Sales_Amount_Nbr__c!=null ){
                        accSalesCombination.get(vxData.PRM_Account_Id__c).add(combNew);
                        vxMap.get(vxData.PRM_Account_Id__c).put(vxData.PRM_Sales_Amount_Nbr__c, vxData.PRM_Sales_Calculation_Group_Txt__c);
                        uniqueRecIdsSet.add(vxData.Id);
                    }
                }
                if(str==system.Label.PRM_Current_measurement_period ){
                   /* if(!trainingNewMap.containsKey(vxData.PRM_TimePeriod_Nm__c+vxData.PRM_Account_Id__c)){
                        sumOfTrainingAmt = trainingNewMap.get(vxData.PRM_TimePeriod_Nm__c+vxData.PRM_Account_Id__c);
                        oldTrainingAmt= oldTrainingAmt + trainingOldMap.get(vxData.PRM_TimePeriod_Nm__c+','+vxData.PRM_Account_Id__c);
                        if (sumOfTrainingAmt == null && oldTrainingAmt != null) {
                            totalAmt = oldTrainingAmt;
                        }
                        else if(oldTrainingAmt == null && sumOfTrainingAmt != null){
                            totalAmt = sumOfTrainingAmt;
                        }
                        else if(oldTrainingAmt == null && sumOfTrainingAmt == null){
                            totalAmt = 0;
                        }
                        else{
                            totalAmt = sumOfTrainingAmt + oldTrainingAmt;
                        }
                        trainingNewMap.put(vxData.PRM_TimePeriod_Nm__c+vxData.PRM_Account_Id__c,totalAmt);
                        totalTrainingCurrent= (decimal)trainingNewMap.get(vxData.PRM_TimePeriod_Nm__c+vxData.PRM_Account_Id__c);
                        //Adding the logic in where condition to pick all the vx data where it is equal to accID instead of Uniquerecidset.
                        //PRB10049494 Problem Ticket fix
                      //  trainingCurrentList = [SELECT max(PRM_Training_Credit_Points_Count_Nbr__c) trainingDashCredi from PRM_Value_Exchange_Data__c WHERE PRM_One_Partner_Id__c =:accID and PRM_TimePeriod_Nm__c=:system.Label.PRM_Current_measurement_period group by PRM_One_Partner_Id__c];
                    }*/
                    trainingCurMap.put(vxData.PRM_Account_Id__c,vxData.PRM_Training_Credit_Points_Count_Nbr__c);                                                       
                }
                if(str==system.Label.PRM_Previous_Measurement_Period){
                   /* if(!trainingNewMap.containsKey(vxData.PRM_TimePeriod_Nm__c+vxData.PRM_Account_Id__c)){
                        sumOfTrainingAmtpre = trainingNewMap.get(vxData.PRM_TimePeriod_Nm__c+vxData.PRM_Account_Id__c);
                        oldTrainingAmtpre= oldTrainingAmtpre+trainingOldMap.get(vxData.PRM_TimePeriod_Nm__c+','+vxData.PRM_Account_Id__c);// key
                        if (sumOfTrainingAmtpre == null && oldTrainingAmtpre != null) {
                            totalAmtpre = oldTrainingAmtpre;
                        }
                        else if(oldTrainingAmtpre == null && sumOfTrainingAmtpre != null){
                            totalAmtpre = sumOfTrainingAmtpre;
                        }
                        else if(oldTrainingAmtpre == null && sumOfTrainingAmtpre == null){
                            totalAmtpre = 0;
                        }
                        else{
                            totalAmtpre = sumOfTrainingAmtpre + oldTrainingAmtpre;
                        }
                        trainingNewMap.put(vxData.PRM_TimePeriod_Nm__c+vxData.PRM_Account_Id__c,totalAmtpre);
                       // totalTrainingPrev= (decimal)trainingNewMap.get(vxData.PRM_TimePeriod_Nm__c+vxData.PRM_Account_Id__c);  
                        
                    }*/
                    trainingPrevMap.put(vxData.PRM_Account_Id__c,vxData.PRM_Training_Credit_Points_Count_Nbr__c);                                                       
                }
            }
            //system.debug('uniqueRecIdsSetcuu-->'+uniqueRecIdsSet);
            dataList = [SELECT sum(PRM_Sales_Amount_Nbr__c) sales from PRM_Value_Exchange_Data__c WHERE Id IN:uniqueRecIdsSet and PRM_TimePeriod_Nm__c=:Label.PRM_Current_measurement_period group by PRM_One_Partner_Id__c];
            dataListPrev = [SELECT sum(PRM_Sales_Amount_Nbr__c) salesprev from PRM_Value_Exchange_Data__c WHERE Id IN:uniqueRecIdsSet and PRM_TimePeriod_Nm__c=:Label.PRM_Previous_Measurement_Period group by PRM_One_Partner_Id__c];
            //Adding the logic in where condition to pick all the vx data where it is equal to accID instead of Uniquerecidset.
            //PRB10049494 Problem Ticket fix
            //dataListTrained = [SELECT sum(PRM_Number_Of_Employees_Nbr__c) totalTrained,max(PRM_Number_Of_Employees_Nbr__c) totalTrainedMax from PRM_Value_Exchange_Data__c WHERE PRM_One_Partner_Id__c =:accID and PRM_TimePeriod_Nm__c=:Label.PRM_Current_measurement_period group by PRM_One_Partner_Id__c];
            dataListTrainedSum = [SELECT max(PRM_Number_Of_Employees_Nbr__c) totalTrained,PRM_Account_Id__c from PRM_Value_Exchange_Data__c WHERE PRM_One_Partner_Id__c =:accID and PRM_TimePeriod_Nm__c=:Label.PRM_Previous_Measurement_Period group by PRM_One_Partner_Id__c,PRM_Account_Id__c]; //TWC727-571 - Utkarsh - Updated where condition in the query for field PRM_TimePeriod_Nm__c. Earlier we were fetching 'Total no of employee' data based on current time period but as part of the story we have to show it for previous time period.
            //totalApprovedOfferingList = getTotalApprovedOfferings(accID);//IPA2.0 TWC727-3228 
            //isPublishedStorefront = getPublishedStorefront(accId,acc.Core_IPA_One_Partner_Id__c);  //IPA2.0 TWC727-3228          
            for(Decimal i:trainingCurMap?.values()){
                            sumCurrent+=i;
            } 
            for(Decimal i:trainingPrevMap?.values()){
                            sumPrevious+=i;
            } 
            totalTrainingCurrent=sumCurrent;
            totalTrainingPrev=sumPrevious;
            //IPA2.0: US-TWC729-7976
            //totalApprovedSolutionsList=[select count(PSS_Partner_Account_Id__c) approvedSolution from ArdiraSurvey__Survey_Result__c where PSS_OPID_Account_Id__c= :accID and PSS_Partner_Solution_Lifecycle_Status_Nm__c in ('Converted To MP Offerings', 'Approved') group by PSS_OPID_Account_Id__c];
        }
        if(acc.RecordType.DeveloperName=='Mastered_Account'){
            whereClause = 'where PRM_Account_Id__c =:accID group by PRM_Account_Id__c';
            for(PRM_Value_Exchange_Data__c vxData: [SELECT Id,PRM_TimePeriod_Nm__c,PRM_Account_Id__c,PRM_Sales_Amount_Nbr__c,PRM_Sales_Calculation_Group_Txt__c/*, PRM_Training_Credit_Points_Count_Nbr__c,PRM_To_Dt__c, PRM_Number_Of_Employees_Nbr__c,PRM_From_Dt__c,PRM_Training_Credit_Points_Report_Nbr__c*/ from PRM_Value_Exchange_Data__c WHERE PRM_Account_Id__c =:accID]){//ATHR Fix - TWC729-9556 - JB
                if(!vxMap.containsKey(vxData.PRM_Account_Id__c)) {
                    if(vxData.PRM_Sales_Amount_Nbr__c !=null){
                        List<string> salesGrp = new List<string>();
                        salesGrp.add(vxData.PRM_Sales_Amount_Nbr__c+vxData.PRM_Sales_Calculation_Group_Txt__c+vxData.PRM_TimePeriod_Nm__c);                       
                        vxValuesMap.put(vxData.PRM_Sales_Amount_Nbr__c, vxData.PRM_Sales_Calculation_Group_Txt__c);
                        accSalesCombination.put(vxData.PRM_Account_Id__c,salesGrp);                        
                        vxMap.put(vxData.PRM_Account_Id__c, vxValuesMap);
                        uniqueRecIdsSet.add(vxData.Id);
                    }
                }
                else{
                     List<String> comb = accSalesCombination.get(vxData.PRM_Account_Id__c);
                    string combNew = vxData.PRM_Sales_Amount_Nbr__c+vxData.PRM_Sales_Calculation_Group_Txt__c+vxData.PRM_TimePeriod_Nm__c;                    
                    if((!comb.contains(combNew)) && (vxData.PRM_Sales_Amount_Nbr__c!=null)){
                        vxMap.get(vxData.PRM_Account_Id__c).put(vxData.PRM_Sales_Amount_Nbr__c, vxData.PRM_Sales_Calculation_Group_Txt__c);
                        uniqueRecIdsSet.add(vxData.Id);
                    }
                }
            }
            
            dataList = [SELECT sum(PRM_Sales_Amount_Nbr__c) sales from PRM_Value_Exchange_Data__c WHERE Id IN:uniqueRecIdsSet and PRM_TimePeriod_Nm__c=:system.Label.PRM_Current_measurement_period group by PRM_Account_Id__c];
            //Adding the logic in where condition to pick all the vx data where it is equal to accID instead of Uniquerecidset.
            //PRB10049494 Problem Ticket fix
            trainingValdataList = [SELECT max(PRM_Training_Credit_Points_Count_Nbr__c) trainingCredi from PRM_Value_Exchange_Data__c WHERE PRM_Account_Id__c =:accID and PRM_TimePeriod_Nm__c=:system.Label.PRM_Current_measurement_period group by PRM_Account_Id__c];
            
            dataListPrev = [SELECT sum(PRM_Sales_Amount_Nbr__c) salesprev from PRM_Value_Exchange_Data__c WHERE Id IN:uniqueRecIdsSet and PRM_TimePeriod_Nm__c=:system.Label.PRM_Previous_Measurement_Period group by PRM_Account_Id__c];
            //Adding the logic in where condition to pick all the vx data where it is equal to accID instead of Uniquerecidset.
            //PRB10049494 Problem Ticket fix
            trainingValdataListprev = [SELECT max(PRM_Training_Credit_Points_Count_Nbr__c) trainingCrediprev from PRM_Value_Exchange_Data__c WHERE PRM_Account_Id__c =:accID and PRM_TimePeriod_Nm__c=:system.Label.PRM_Previous_Measurement_Period group by PRM_Account_Id__c];
            //Adding the logic in where condition to pick all the vx data where it is equal to accID instead of Uniquerecidset.
            //PRB10049494 Problem Ticket fix
            dataListTrained = [SELECT max(PRM_Number_Of_Employees_Nbr__c) totalTrained from PRM_Value_Exchange_Data__c WHERE PRM_Account_Id__c =:accID and PRM_TimePeriod_Nm__c=:Label.PRM_Previous_Measurement_Period group by PRM_Account_Id__c]; // //TWC727-571 - Utkarsh - Updated where condition in the query for field PRM_TimePeriod_Nm__c. Earlier we were fetching 'Total no of employee' data based on current time period but as part of the story we have to show it for previous time period.
                
            //totalApprovedOfferingList = getTotalApprovedOfferings(accID);//IPA2.0 TWC727-3228
            //isPublishedStorefront = getPublishedStorefront(accId,acc.Core_IPA_One_Partner_Id__c);//IPA2.0 TWC727-3228
            //Adding the logic in where condition to pick all the vx data where it is equal to accID instead of Uniquerecidset.
            //PRB10049494 Problem Ticket fix
            trainingCurrentList = [SELECT max(PRM_Training_Credit_Points_Count_Nbr__c) trainingDashCredi from PRM_Value_Exchange_Data__c WHERE PRM_Account_Id__c =:accID and PRM_TimePeriod_Nm__c=:system.Label.PRM_Current_measurement_period group by PRM_Account_Id__c];
            //totalApprovedSolutionsList=getTotalApprovedSolutions(accID);//IPA2.0: US-TWC729-7976
        }
        
        Decimal totalPointsEarned;
        Decimal totalSalesData;
        Decimal totalTrainedResources =0;
        Decimal totalTrainedResourcesMax;    
        Decimal totalPointsExpired;
        Decimal totalAWRallocated;
        Decimal totalAWRremaining;
        Decimal totalPointsBalance;
        Decimal totalSalesDataPrevPeriod;
        //Decimal totalApprovedOffering;//IPA2.0 TWC727-3228
        Decimal totalTrainingDataDash;
	    //Decimal	totalApprovedSolutions;//IPA2.0: US-TWC729-7976
        List<Account> accounts = new List<Account>();
        HttpRequest httpReq = new HttpRequest();
        HttpResponse response = new HttpResponse();
        
        /*TWC727-120 - start - utkarsh - code changes done to fetch real points data on run time from collinsion*/
        try{
            if(accID!= null){
                accounts = [SELECT Id,Core_OnePartnerID__c,AccountNumber FROM Account WHERE id=:accID];
            }
            PRM_Integration__mdt apiDetails = [Select Id, API_Key__c, EndPointURL__c, Password__c, Username__c from PRM_Integration__mdt where MasterLabel='RealTimePointData'];
            if(apiDetails!=null){
                if(accounts.size() > 0) {
                    string token = getToken(apiDetails) != null ? getToken(apiDetails).access_token : null;
                    if(token != null || String.isNotBlank(token)) {
                        httpReq = new  HttpRequest();    
                        httpReq.setEndpoint(apiDetails.EndPointURL__c);
                        httpReq.setHeader(PRM_IPA_Constants.Authorization, PRM_IPA_Constants.Bearer +token);
                        httpReq.setHeader('Content-Type', 'application/xml');
                        String prebaseBody1 = '<?xml version="1.0" encoding="UTF-8"?>';
                        String prebaseBody2 ='<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="urn:xmethods" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">';
                        String baseBody = prebaseBody1 + prebaseBody2 + '<SOAP-ENV:Body><ns1:invokeService>'+
                            '<requestId xsi:type="xsd:string">'+Label.PRM_Collinsion_ClientId+'</requestId>'+
                            '<requestorId xsi:type="xsd:string">Intel</requestorId>'+
                            '<requestorPassword xsi:type="xsd:string">'+Label.PRM_Collinsion_Password+'</requestorPassword>'+
                            '<request xsi:type="xsd:string">&lt;request&gt;&#13;'+
                            '&lt;function&gt;getMemberBalance12&lt;/function&gt;&#13;'+
                            '&lt;org_acct_nbr&gt;{{accountNumber}}&lt;/org_acct_nbr&gt;&#13;'+
                            '&lt;/request&gt;</request>'+
                            '</ns1:invokeService>'+
                            '</SOAP-ENV:Body>'+
                            '</SOAP-ENV:Envelope>';
                        baseBody = baseBody.replace('{{accountNumber}}',accounts[0].AccountNumber);
                        httpReq.setBody(baseBody);
                        httpReq.setMethod('POST');
                        httpReq.setTimeout(Integer.valueOf(Label.APIGEETimeout));
                        //system.debug('httpReq-->'+httpReq);
                        //system.debug('httpReq get body-->'+httpReq.getBody());
                        response = new Http().send(httpReq);
                        
                        if(response.getStatusCode() != 200 || response.getBody().indexOf('ErrorCode') > -1){
                            CustomException ex = new CustomException();                    
                            ex.Message = response.getBody();                          
                            ex.StackTraceString = 'Collinsion API Error';
                            createErrorRecordWrapper errorRecord=new createErrorRecordWrapper();
                            errorRecord.msg='Unable to Initiate Sync Request';
                            errorRecord.acc=accounts[0];
                            errorRecord.ex=ex;
                            errorRecord.severity=LOG_ENTRY_ERROR;
                            createErrorRecord(errorRecord); 
                            //createErrorRecord('Unable to Initiate Sync Request', accounts[0], ex, LOG_ENTRY_ERROR); 
                        }else{
                            //system.debug('Response ===>'+EncodingUtil.urlDecode(response.getBody(), 'UTF-8'));
                            String responseBody = response.getBody().replaceAll('&lt;','<').replaceAll('&gt;','>');
                            
                            responseBody = responseBody.replace(responseBody.substringBefore('<response>'),'').replace(responseBody.substringAfter('</response>'),'');
                            //system.debug('responseBody ===>'+responseBody);
                            
                            createRealTimePointDataRecord(responseBody, accounts[0]); 
                        }
                    }
                }
            }
            else{
                CustomException ex = new CustomException();                    
                ex.Message = 'End Point Record is not available';                          
                ex.StackTraceString = 'PRM_Integration__mdt'; 
                createErrorRecordWrapper errorRecord=new createErrorRecordWrapper();
                errorRecord.msg=ex.Message;
                errorRecord.acc=accounts[0];
                errorRecord.ex=ex;
                errorRecord.severity=LOG_ENTRY_ERROR;
              createErrorRecord(errorRecord); 
                //createErrorRecord(ex.Message, accounts[0], ex, LOG_ENTRY_ERROR);
            }
        }catch(Exception ex){
            CustomException custEx = createException(ex);
            createErrorRecordWrapper errorRecord=new createErrorRecordWrapper();
            errorRecord.msg='Issue in Record Id';
            errorRecord.acc=accounts[0];
            errorRecord.ex=custEx;
            errorRecord.severity=LOG_ENTRY_ERROR;
            //createErrorRecord('Issue in Record Id', accounts[0], custEx, LOG_ENTRY_ERROR);  
            createErrorRecord(errorRecord);             
        }
        finally
        {
            // Calling the utility method to create Integration log record
            //PRM_IPA_Utility.createIntegrationLog(accID,PRM_IPA_Constants.CALLOUT_TYPE_OUTBOUND,PRM_IPA_Constants.MODULE_RealTimepointsData,constructRealPointDataJSON(accounts),response.getBody(),response.getStatusCode(),PRM_IPA_Constants.SYSTEM_NAME_Collinsion,'PRM_AccountActvityOverview');         
            
        }
        //Added as part of US-1636 for PointsBalance metrics.
            //String query = 'SELECT max(PRM_Total_Points_Due_to_Expire_Nbr__c) pointsEpiringSoon,max(PRM_Points_Balance__c) pointsBalance from PRM_Points_Data__c' +' '+whereClause;       
            String query = '';
            if(acc.RecordType.DeveloperName=='Core_Partner_Account_Group'){
              query = 'SELECT max(PRM_Total_Points_Due_to_Expire_Nbr__c) pointsEpiringSoon,max(PRM_Points_Balance__c) pointsBalance from PRM_Points_Data__c where PRM_One_Partner_Id__c =:accID';
            }else{
              query = 'SELECT max(PRM_Total_Points_Due_to_Expire_Nbr__c) pointsEpiringSoon,max(PRM_Points_Balance__c) pointsBalance from PRM_Points_Data__c where PRM_Account_Id__c =:accID';    
            }
            
        
        //System.debug('Query'+query);
        for(AggregateResult dt :Database.query(query)){ // aggregate result
            totalPointsExpired =(Decimal)dt.get('pointsEpiringSoon');
            totalPointsBalance =(Decimal)dt.get('pointsBalance');
        }
        
        //Sales Calculation
        for(AggregateResult vx: dataList){
            totalSalesData =(Decimal)vx.get('sales');
        }
        
        for(AggregateResult vx: dataListPrev){
            totalSalesDataPrevPeriod =(Decimal)vx.get('salesprev');
        }
        
        //Training Calculation
        for(AggregateResult vx: trainingValdataList){
            totalTrainingCurrent =(Decimal)vx.get('trainingCredi');
        }

        for(AggregateResult vx: trainingCurrentList){
                totalTrainingDataDash =(Decimal)vx.get('trainingDashCredi');
        }
        
        for(AggregateResult vx: trainingValdataListprev){
            totalTrainingPrev =(Decimal)vx.get('trainingCrediprev');
        }
        
        for(AggregateResult vx: dataListTrained){
            totalTrainedResources = (Decimal)vx.get('totalTrained');
        }
           /* for(AggregateResult vx: dataListTrained){
            totalTrainedResourcesMax = (Decimal)vx.get('totalTrainedMax');
            system.debug('totalTrainedResources'+totalTrainedResources);
        }*/
        for(AggregateResult vx: dataListTrainedSum){
            totalTrainedResources = totalTrainedResources + (Decimal)vx.get('totalTrained');
        }
        
        //Offering Calculation
        // for(AggregateResult vx: totalApprovedOfferingList){
        //     totalApprovedOffering = (Decimal)vx.get('approvedOffer');
        // }
        //IPA2.0 TWC727-3228
     //ApprovedSolutions Calculation//IPA2.0: US-TWC729-7976
        /*for(AggregateResult vx: totalApprovedSolutionsList){
            totalApprovedSolutions = (Decimal)vx.get('approvedSolution');
        }*/
            if(whereClause != null){
                String uxQuery='SELECT sum(PRM_Number_Of_AWR_Remaining_Nbr__c) remaining,sum(PRM_Number_Of_AWR_Used_Nbr__c)allocated from PRM_Warranty_Data__c '+' '+whereClause;
                //System.debug('Query'+uxQuery);
                for( AggregateResult ux: Database.query(uxQuery)){ // aggregate result
                    totalAWRremaining=(Decimal)ux.get('remaining');
                    totalAWRallocated=(Decimal)ux.get('allocated');
            }
            }
        
        
        // assign data to wrapper
        rs.totalPointsEarned =totalPointsEarned!=Null ? totalPointsEarned:0;
        rs.totalPointsExpired = totalPointsExpired!=Null ? totalPointsExpired:0;
        rs.totalSalesData =totalSalesData!=Null ? totalSalesData:0;
        rs.totalSalesDataPrevPeriod=totalSalesDataPrevPeriod!=Null ? totalSalesDataPrevPeriod:0;
        rs.totalTrainingCredits=totalTrainingCurrent!=Null ? totalTrainingCurrent:0;
        rs.totalTrainingDataDash=totalTrainingDataDash!=Null ? totalTrainingDataDash:0;
        rs.totalTrainingCreditsPrevPeriod=totalTrainingPrev!=Null?totalTrainingPrev:0;
        rs.totalAWRallocated=totalAWRallocated!=Null ? totalAWRallocated:0;
        rs.totalAWRremaining=totalAWRremaining!=Null ? totalAWRremaining:0;
        rs.totalPointsBalance=totalPointsBalance!=Null ? totalPointsBalance:0;
        rs.totalTrainedResources=totalTrainedResources!=Null ? totalTrainedResources:0;
        //rs.totalApprovedOffering = totalApprovedOffering!=Null ? totalApprovedOffering:0; //IPA2.0 TWC727-3228
        //rs.publishedStorefront = isPublishedStorefront!=Null ? isPublishedStorefront:false;//IPA2.0 TWC727-3228
        rs.totalTrainedResourcesMax = totalTrainedResourcesMax!=Null ?totalTrainedResourcesMax:0;  
        /*rs.totalApprovedSolutions=    totalApprovedSolutions!=Null? totalApprovedSolutions: 0;*/ //IPA2.0: US-TWC729-7976    
        }catch(Exception e){
            rs = new responseWrapper();
            PRM_ErrorUtilityClass.logError(e);
        }
        return rs;
    }
    
    public static PRM_Token_Model getToken(PRM_Integration__mdt apiDetails) {
        PRM_Token_Model token = new PRM_Token_Model();
        try{
            HttpRequest httpReq = new  HttpRequest();
            httpReq.setEndpoint(apiDetails.API_Key__c);
            httpReq.setMethod( 'POST' );
            httpReq.setHeader('content-type', 'application/x-www-form-urlencoded');
            
            //string gType = EncodingUtil.urlEncode('client_credentials','UTF-8');
            String payLoad = 'grant_type=client_credentials&client_id=' + EncodingUtil.urlEncode(apiDetails.Username__c,'UTF-8') +'&client_secret=' + EncodingUtil.urlEncode(apiDetails.Password__c, 'UTF-8');
            //system.debug('payload- '+payload);       
            httpReq.setBody(payLoad);
            //system.debug('>>>>httpReq'+httpReq.getEndpoint());
            HttpResponse response;
            if(!Test.isRunningTest()){
                response = new Http().send(httpReq); 
            }else{
                response = new HttpResponse();
                response.setBody('{"access_token": "TestToken124","token_type": "Bearer","expires_in": "3599","ext_expires_in": "3599"}');
                response.setStatusCode(200);
            }
            
            if(response.getStatusCode() == 200 ) {
                //system.debug('Response ===>'+EncodingUtil.urlDecode(response.getBody(), 'UTF-8'));
                token = PRM_Token_Model.parse(response.getBody());
                Cache.Org.put('local.PRMIPAPartition.APIGEEaccesstoken',token.access_token, Integer.valueOf(Label.APIGEETokenExpiryTime),Cache.Visibility.ALL, true);
            }
            else {
                //system.debug('response- '+response.getBody());
                CustomException ex = new CustomException();                    
                ex.Message = 'Error in token generation -'+response.getBody();  
                createErrorRecordWrapper errorRecord=new createErrorRecordWrapper();
                errorRecord.msg=ex.Message;
                errorRecord.acc=null;
                errorRecord.ex=ex;
                errorRecord.severity=LOG_ENTRY_ERROR;
                //createErrorRecord(ex.Message, null, ex, LOG_ENTRY_ERROR);
                createErrorRecord(errorRecord);
            }
        }
        catch(Exception ex){
            CustomException custEx = createException(ex);
            createErrorRecordWrapper errorRecord=new createErrorRecordWrapper();
            errorRecord.msg='API token issue';
            errorRecord.acc=null;
            errorRecord.ex=custEx;
            errorRecord.severity=LOG_ENTRY_ERROR;
            //createErrorRecord('API token issue', null, custEx, LOG_ENTRY_ERROR); 
            createErrorRecord(errorRecord); 
        }
        return token;
    }
    
    public class responseWrapper {
        
        @AuraEnabled
        public Decimal totalPointsEarned {get;set;}
        @AuraEnabled
        public Decimal totalPointsExpired {get;set;}
        @AuraEnabled
        public Decimal totalSalesData {get;set;}
        @AuraEnabled
        public Decimal totalTrainingCredits {get;set;}
        @AuraEnabled
        public Decimal totalAWRallocated {get;set;}
        @AuraEnabled
        public Decimal totalAWRremaining {get;set;}
        @AuraEnabled
        public Decimal totalPointsBalance {get;set;}
        @AuraEnabled
        public Decimal totalSalesDataPrevPeriod {get;set;}
        @AuraEnabled
        public Decimal totalTrainingCreditsPrevPeriod {get;set;}
        @AuraEnabled
        public Decimal totalTrainedResources {get;set;}
        // @AuraEnabled
        // public Decimal totalApprovedOffering {get;set;}//IPA2.0 TWC727-3228
        @AuraEnabled
        public Decimal totalTrainingDataDash {get;set;}
        // @AuraEnabled
        // public Boolean publishedStorefront {get;set;}//IPA2.0 TWC727-3228
        @AuraEnabled
        public Decimal totalTrainedResourcesMax {get;set;}
    // @AuraEnabled
        // public Decimal totalApprovedSolutions {get;set;}//IPA2.0 TWC727-3228
    }
    
    @AuraEnabled
    public static string getAccountId(){
        User user = [select Id,Name,ContactId,isportalenabled from User where Id = :UserInfo.getUserId()];
        Contact con = [select Id, AccountId,account.Core_IPA_One_Partner_Id__c from Contact where Id = :user.ContactId];
        if(con.account.Core_IPA_One_Partner_Id__c != null){
            return con.account.Core_IPA_One_Partner_Id__c;
        }     
            return con.AccountId;
    }
    /* public static void createErrorRecord(String msg, Account acc, CustomException ex, String severity){
        try{ 
            Id recId = acc?.Id;
            String strDetailsAndEx = '';
            strDetailsAndEx += 'Message: ' + ex.Message + '\n';
            strDetailsAndEx += 'Cause: ' + ex.Cause + '\n';
            strDetailsAndEx += 'Line Number: ' + ex.LineNumber + '\n';
            strDetailsAndEx += 'Stack Trace: ' + ex.StackTraceString + '\n';
            strDetailsAndEx += 'Type Name: ' + ex.TypeName + '\n';
            if(recId != null){
                //Creating error records
                PRM_RealTimePointsData__c rtpd = new PRM_RealTimePointsData__c();
                rtpd.PRM_AccountBizId__c = acc.AccountNumber;
                rtpd.PRM_AccountId__c = acc.Id;
                rtpd.PRM_Status__c = 'Failed';
                rtpd.PRM_Status_Reason__c = strDetailsAndEx;
                insert rtpd;
            }
            
        }catch(Exception e){
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'' ,'' , '', '', '',e);
        }
        
    } */ //ATHR fixes
    
    public class createErrorRecordWrapper{
        public String msg {get;set;}
        public Account acc{get;set;}
        public CustomException ex{get;set;}
        public String severity{get;set;}
    }
    
    public static void createErrorRecord(createErrorRecordWrapper att){
        try{ 
            Id recId = att.acc?.Id;
            String strDetailsAndEx = '';
            strDetailsAndEx += 'Message: ' + att.ex.Message + '\n';
            strDetailsAndEx += 'Cause: ' + att.ex.Cause + '\n';
            strDetailsAndEx += 'Line Number: ' + att.ex.LineNumber + '\n';
            strDetailsAndEx += 'Stack Trace: ' + att.ex.StackTraceString + '\n';
            strDetailsAndEx += 'Type Name: ' + att.ex.TypeName + '\n';
            if(recId != null){
                //Creating error records
                PRM_RealTimePointsData__c rtpd = new PRM_RealTimePointsData__c();
                rtpd.PRM_AccountBizId__c = att.acc.AccountNumber;
                rtpd.PRM_AccountId__c = att.acc.Id;
                rtpd.PRM_Status__c = 'Failed';
                rtpd.PRM_Status_Reason__c = strDetailsAndEx;
                insert rtpd;
            }
            
        }catch(Exception e){
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'' ,'' , '', '', '',e);
        }
        
    }
    
    public static void createRealTimePointDataRecord(String msg, Account acc){
        //system.debug('msg-->'+msg);
        //system.debug('Account-->'+acc);
        try{
            Id recId,syncObjRecId; 
            //String strDetailsAndEx = '';
            List<PRM_Points_Data__c> pointsdata = new List<PRM_Points_Data__c>();
            if(acc != null && msg != null){
                recId = acc.Id;
                PRM_RealTimePointsData__c rtpd = new PRM_RealTimePointsData__c();
                rtpd.PRM_AccountBizId__c = acc.AccountNumber;
                rtpd.PRM_AccountId__c = acc.Id;
                rtpd.PRM_Response__c = msg;
                rtpd.PRM_Status__c = 'Success';
                insert rtpd;
                syncObjRecId = rtpd.Id;
            }
            //if(msg.length() > 10 && !msg.contains('No Data retrieved')){
                //system.debug('>>>>>listval'+[Select id, PRM_Account_Id__c,PRM_Change_Date_Time_Dt__c,DQ_Flag__c,PRM_End_Date_Dt__c,PRM_Inactive_Indicator__c,PRM_One_Partner_Id__c,PRM_Points_Balance__c,PRM_Total_Points_Due_to_Expire_Nbr__c,PRM_Points_ext_id__c,PRM_Start_Date_Dt__c,PRM_Total_Points_Available_Nbr__c,PRM_Total_Points_Earned_Nbr__c,PRM_Total_Points_Expired_Nbr__c,PRM_Total_Points_Redeemed_Nbr__c From PRM_Points_Data__c]);
                //pointsdata = [Select id, PRM_Account_Id__c,PRM_Change_Date_Time_Dt__c,DQ_Flag__c,PRM_End_Date_Dt__c,PRM_Inactive_Indicator__c,PRM_One_Partner_Id__c,PRM_Points_Balance__c,PRM_Total_Points_Due_to_Expire_Nbr__c,PRM_Points_ext_id__c,PRM_Start_Date_Dt__c,PRM_Total_Points_Available_Nbr__c,PRM_Total_Points_Earned_Nbr__c,PRM_Total_Points_Expired_Nbr__c,PRM_Total_Points_Redeemed_Nbr__c From PRM_Points_Data__c Where PRM_Account_Id__c =: acc.Id AND DQ_Flag__c != false];
              //TWC729-7584 - ApexGuru
              pointsdata = [Select id, PRM_Account_Id__c,PRM_Change_Date_Time_Dt__c,DQ_Flag__c,PRM_End_Date_Dt__c,PRM_Inactive_Indicator__c,PRM_One_Partner_Id__c,PRM_Points_Balance__c,PRM_Total_Points_Due_to_Expire_Nbr__c,PRM_Points_ext_id__c,PRM_Start_Date_Dt__c,PRM_Total_Points_Available_Nbr__c,PRM_Total_Points_Earned_Nbr__c,PRM_Total_Points_Expired_Nbr__c,PRM_Total_Points_Redeemed_Nbr__c From PRM_Points_Data__c Where PRM_Account_Id__c =: acc.Id AND DQ_Flag__c = true];

            //}
            
            //Deserialize the JSON response - 
            //List<Map<String, String>> wrapList = new List<Map<String, String>>();
            Dom.Document doc = new Dom.Document();
            doc.load(msg);
            Map<String,String> responseMap = new Map<String,String>();
            
            for(Dom.XmlNode node :doc.getRootElement().getChildElements()){
                responseMap.put(node.getName(),node.getText());
            }
            List<PRM_Points_Data__c> pointsDataList = new List<PRM_Points_Data__c>();
            
            Boolean toBeUpdated;
            if(pointsdata != null && !pointsdata.IsEmpty()){
                for(PRM_Points_Data__c pd : pointsdata){
                    toBeUpdated = false;
                    if(responseMap.containsKey('qtr_due_to_expire_points') && pd.PRM_Total_Points_Due_to_Expire_Nbr__c != Decimal.valueOf(responseMap.get('qtr_due_to_expire_points'))){
                        pd.PRM_Total_Points_Due_to_Expire_Nbr__c =  Decimal.valueOf(responseMap.get('qtr_due_to_expire_points'));
                        toBeUpdated = true;
                    }
                    if(responseMap.containsKey('current_balance') && pd.PRM_Points_Balance__c != Decimal.valueOf(responseMap.get('current_balance'))){
                        pd.PRM_Points_Balance__c = Decimal.valueOf(responseMap.get('current_balance'));
                        toBeUpdated = true;
                    }
                    if( responseMap.containsKey('data_correctness') && pd.DQ_Flag__c != (responseMap.get('data_correctness') == '1' ? true : false )){
                        pd.DQ_Flag__c = responseMap.get('data_correctness') == '1' ? true : false;
                        toBeUpdated = true;
                    }
                    
                    if(toBeUpdated){
                        pointsDataList.add(pd);
                    }
                }
            }
            else{
                PRM_Points_Data__c point = new PRM_Points_Data__c();
                point.PRM_Account_Id__c = acc.Id;
                point.PRM_Business_Id__c = responseMap.containsKey('bizid') ?  Decimal.valueOf(responseMap.get('bizid')): null;
                point.PRM_Total_Points_Due_to_Expire_Nbr__c = responseMap.containsKey('qtr_due_to_expire_points') ?  Decimal.valueOf(responseMap.get('qtr_due_to_expire_points')): null;
                point.PRM_Points_Balance__c = responseMap.containsKey('current_balance') ?  Decimal.valueOf(responseMap.get('current_balance')): null;
                point.DQ_Flag__c = responseMap.containsKey('data_correctness') ?  responseMap.get('data_correctness') == '1' ? true : false : false;
                pointsDataList.add(point);
            }
            
            if(pointsDataList != null && !pointsDataList.IsEmpty()){
                upsert pointsDataList;
            }
        }
        catch(Exception e){
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'' ,'' , '', '', '',e);
        }
    }
    public static CustomException createException(Exception ex){
        CustomException custEx = new CustomException();
        custEx.Message = ex.getMessage();
        custEx.Cause = ex.getCause();
        custEx.StackTraceString = ex.getStackTraceString();
        custEx.LineNumber = ex.getLineNumber();                
        custEx.TypeName = ex.getTypeName();
        return custEx;
    }
    
    public class CustomException extends Exception {
        public String message {set;get;}
        public Exception cause {set;get;}
        public Integer lineNumber {set;get;}
        public String stackTraceString {set;get;}
        public String typeName {set;get;}
    }
    
    //US TWC729-3538
    /* public static List<AggregateResult> getTotalApprovedOfferings(Id accID){
        String startDate = System.Label.PRM_Start_Date_for_AppOfferings;
        String endDate = System.Label.PRM_EndDate_For_AppOfferings;
        //Date startDateApp = Date.valueOf(startDate);
        //Date endDateApp = Date.valueOf(endDate);
        Account acc = [select id, name, Core_IPA_One_Partner_Id__c from Account where id=: accID];
        List<AggregateResult> ApprovedOfferingList = new List<AggregateResult>();
        List<PMP_OPID_MPI_Rel__c> mpirecords = new  List<PMP_OPID_MPI_Rel__c>();
        if(acc.Core_IPA_One_Partner_Id__c != null){
            mpirecords = [select id,PMP_One_Partner_ID__c,PMP_Marketing_Profile_Id__c,Is_Active__c from PMP_OPID_MPI_Rel__c where PMP_One_Partner_ID__c =:acc.Core_IPA_One_Partner_Id__c and Is_Active__c = true limit 1];
        }
        else{
            mpirecords = [select id,PMP_One_Partner_ID__c,PMP_Marketing_Profile_Id__c,Is_Active__c from PMP_OPID_MPI_Rel__c where PMP_One_Partner_ID__c =:accId and Is_Active__c = true limit 1];
        }


            if(mpirecords!=null && !mpirecords.isEmpty()){
                //List<PMP_Company__c> companyrecords = [SELECT id, Name, PMP_Partner_Inactive_Ind__c, PMP_Company_Lifecycle_Status_Nm__c, PMP_Partner_Benefit_Type__c from PMP_Company__c where id =: mpirecords[0].PMP_Marketing_Profile_Id__c and PMP_Is_Published_Ind__c=true];
                if(mpirecords[0].PMP_Marketing_Profile_Id__c != null){
                    ApprovedOfferingList = [Select Count(PMP_Company_Id__c) approvedOffer from PMP_Partner_Offering__c where  PMP_Partner_Offering_Lifecycle_Status_Nm__c =:'Approved' 
                                            and PMP_Company_Id__c =:mpirecords[0].PMP_Marketing_Profile_Id__c
                                            and PMP_Partner_Offering_Start_Dt__c <= TODAY 
                                            and PMP_Partner_Offering_End_Dt__c >= TODAY];
                }
            }  
        return ApprovedOfferingList;
    }*/
    //IPA2.0 TWC727-3228
    //IPA2.0: US-TWC729-7976
   /*public static List<AggregateResult> getTotalApprovedSolutions(Id accID){
     List<AggregateResult> approvedSolutionsList = new List<AggregateResult>();
     approvedSolutionsList=[select  count(PSS_Partner_Account_Id__c) approvedSolution from ArdiraSurvey__Survey_Result__c where PSS_Partner_Account_Id__c=: accID 
                and PSS_Partner_Solution_Lifecycle_Status_Nm__c in ('Converted To MP Offerings', 'Approved') ];
     return approvedSolutionsList;
   }*/
    /*public static boolean getPublishedStorefront(Id accId,id opidAcnt){
       // Account acc = [select id, name, Core_IPA_One_Partner_Id__c from Account where id=: accID];
        Boolean isPublished= false;
        List<PMP_OPID_MPI_Rel__c> mpirecords = new  List<PMP_OPID_MPI_Rel__c>();
        if(opidAcnt != null){ 
            mpirecords=[select id,Name,PMP_Marketing_Profile_Id__r.name,PMP_Marketing_Profile_Id__c, Is_Active__c,PMP_Marketing_Profile_Id__r.PMP_Company_Lifecycle_Status_Nm__c,PMP_Marketing_Profile_Id__r.PMP_Is_Published_Ind__c,  PMP_Storefront_Published_Copy__c, PMP_Storefront_Working_Copy__c, PMP_Marketing_Profile_Id__r.PMP_Partner_Benefit_Type__c, PMP_Marketing_Profile_Id__r.PMP_Benefit_Update_Ind__c, PMP_One_Partner_ID__c, PMP_One_Partner_ID__r.name  from PMP_OPID_MPI_Rel__c where Is_Active__c = true and PMP_Marketing_Profile_Id__r.PMP_Company_Lifecycle_Status_Nm__c ='Published' and PMP_Marketing_Profile_Id__r.PMP_Benefit_Update_Ind__c =false and (PMP_Marketing_Profile_Id__r.PMP_Partner_Benefit_Type__c = 'Solutions Marketplace Enhanced' or PMP_Marketing_Profile_Id__r.PMP_Partner_Benefit_Type__c = 'Solutions Marketplace Basic Profile') and PMP_One_Partner_ID__c =:opidAcnt];
        }
        else{
            mpirecords=[select id,Name,PMP_Marketing_Profile_Id__r.name,PMP_Marketing_Profile_Id__c, Is_Active__c,PMP_Marketing_Profile_Id__r.PMP_Company_Lifecycle_Status_Nm__c,PMP_Marketing_Profile_Id__r.PMP_Is_Published_Ind__c,  PMP_Storefront_Published_Copy__c, PMP_Storefront_Working_Copy__c, PMP_Marketing_Profile_Id__r.PMP_Partner_Benefit_Type__c, PMP_Marketing_Profile_Id__r.PMP_Benefit_Update_Ind__c, PMP_One_Partner_ID__c, PMP_One_Partner_ID__r.name  from PMP_OPID_MPI_Rel__c where Is_Active__c = true and PMP_Marketing_Profile_Id__r.PMP_Company_Lifecycle_Status_Nm__c ='Published' and PMP_Marketing_Profile_Id__r.PMP_Benefit_Update_Ind__c =false and (PMP_Marketing_Profile_Id__r.PMP_Partner_Benefit_Type__c = 'Solutions Marketplace Enhanced' or PMP_Marketing_Profile_Id__r.PMP_Partner_Benefit_Type__c = 'Solutions Marketplace Basic Profile') and PMP_One_Partner_ID__c =:accId];
        }

        if(mpirecords.size()>0){
            isPublished=true; 
        }
        return isPublished;
    }*/
    //IPA2.0 TWC727-3228
}