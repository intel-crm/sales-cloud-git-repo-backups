/******************************************************************************************************************************************
Function    : Trigger handler class for the object Forecast Product Schedule
********************************************************************************************************************************************/

public without sharing class Core_Opp_FC_Handler { //TWC3123-5338 Added without sharing keyword to fix code scan issue
    
    /*
    *Method Name: addCommissionableTransaction
    *Parameters: List<Core_Opp_FC_Prod_Schedule__c> forecastList, Map<Id, Core_Opp_FC_Prod_Schedule__c> oldForecastMap
    *Description: Create commissionable transaction when a 6QPS quarter is approved or recalled.
    */
    /*public static void addCommissionableTransaction(List<Core_Opp_FC_Prod_Schedule__c> forecastList, Map<Id, Core_Opp_FC_Prod_Schedule__c> oldForecastMap){
        try{
            List<Core_Commissionable_Transaction__c> commTransList = new List<Core_Commissionable_Transaction__c>();
            Core_Commissionable_Transaction__c trans;
            List<Core_Opp_FC_Prod_Schedule__c> approvedForecastList = new List<Core_Opp_FC_Prod_Schedule__c>();
            List<Core_Opp_FC_Prod_Schedule__c> recalledForecastList = new List<Core_Opp_FC_Prod_Schedule__c>();
            Set<Id> oppIdSet = new Set<Id>();
            Set<Id> oppProductIdSet = new Set<Id>();
            for(Core_Opp_FC_Prod_Schedule__c forecast : forecastList){
                if(oldForecastMap.get(forecast.Id).Core_Opp_FC_Approval_Status__c <> forecast.Core_Opp_FC_Approval_Status__c){
                    if(forecast.Core_Opp_FC_Approval_Status__c == null || forecast.Core_Opp_FC_Approval_Status__c == ''){
                        if(oldForecastMap.get(forecast.Id).Core_Opp_FC_Approval_Status__c <> null && oldForecastMap.get(forecast.Id).Core_Opp_FC_Approval_Status__c == 'Approved'){
                            recalledForecastList.add(forecast);
                        }
                    }else if(forecast.Core_Opp_FC_Approval_Status__c == 'Approved' && oldForecastMap.get(forecast.Id).Core_Opp_FC_Approval_Status__c <> 'Approved'){
                        approvedForecastList.add(forecast);
                        oppIdSet.add(forecast.Core_Opp_FC_Opportunity__c);
                        oppProductIdSet.add(forecast.Core_Opp_Line_Item_RecordID__c);
                    }
                }
            }
            if(!approvedForecastList.isEmpty()){
                Set<Id> accIdSet = new Set<Id>();
                Set<Id> userIdSet = new Set<Id>();
                Map<Id, List<OpportunityTeamMember>> oppTeamMap = new Map<Id, List<OpportunityTeamMember>>();
                List<OpportunityTeamMember> tempList;
                Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([select Id, Name, Core_Opportunity_Type__c, account.Core_Account_Tier__c, account.Core_Account_BU_Focus__c, account.Name, accountId, Core_Commissionable__c, Core_Exclude_From_KPIs__c FROM Opportunity WHERE Id IN :oppIdSet AND Core_Commissionable__c = 'Yes' AND Core_Exclude_From_KPIs__c = false]);
                Map<Id, OpportunityLineItem> oppProdMap = new Map<Id, OpportunityLineItem>([select Id, OpportunityId, Core_Claim_Date__c, Core_Approved_Date__c, Core_Approved_KPI_Product_Group__c, CRM_DW_App_UCD_Customer_Name__c, Core_Product_Segment__c, Core_BU_Product_Segment__c, Core_Opp_Approved_Sales_Group__c, Product2Id, Core_Product_Type__c, Core_BU_Short_Name__c from OpportunityLineItem where Id IN: oppProductIdSet]);
                for(OpportunityTeamMember oppTeam : [select Id, TeamMemberRole, UserId, OpportunityId from OpportunityTeamMember where OpportunityId IN: oppMap.keyset()]){
                    if(oppTeamMap.containskey(oppTeam.OpportunityId)){
                        tempList = oppTeamMap.get(oppTeam.OpportunityId);
                    }else{
                        tempList = new List<OpportunityTeamMember>();
                    }
                    tempList.add(oppTeam);
                    oppTeamMap.put(oppTeam.OpportunityId, tempList);
                    userIdSet.add(oppTeam.UserId);
                }
                Map<Id, User> userMap = new Map<Id, User>([select Id, Name, Core_WWID__c, Core_Employee_Type_Code__c from User where Id IN: userIdSet]);
                
                String tempBUShortName, tempBUFocus, tempAccountTier, tempOpportunityType;
                Map<String, Core_FC_Commission_Criterias__c> FCCommCriteriaMap = new Map<String, Core_FC_Commission_Criterias__c>();
                List<Core_FC_Commission_Criterias__c> FCCriteriaList = Core_FC_Commission_Criterias__c.getall().values();
                if(!FCCriteriaList.isEmpty()){
                    for(Core_FC_Commission_Criterias__c FCCriteria : FCCriteriaList){
                        if(FCCriteria.Core_Is_Active__c){
                            if(FCCriteria.Core_BU_Short_Name__c == null || FCCriteria.Core_BU_Short_Name__c == '' || FCCriteria.Core_BU_Short_Name__c.equalsIgnoreCase('null') || FCCriteria.Core_BU_Short_Name__c.equalsIgnoreCase('any')){
                                tempBUShortName = '<any>';
                            }else{
                                tempBUShortName = FCCriteria.Core_BU_Short_Name__c.toLowerCase();
                            }
                            
                            if(FCCriteria.Core_BU_Focus__c == null || FCCriteria.Core_BU_Focus__c == '' || FCCriteria.Core_BU_Focus__c.equalsIgnoreCase('null') || FCCriteria.Core_BU_Focus__c.equalsIgnoreCase('any')){
                                tempBUFocus = '<any>';
                            }else{
                                tempBUFocus = FCCriteria.Core_BU_Focus__c.toLowerCase();
                            }
                            
                            if(FCCriteria.Core_Account_Tier__c == null || FCCriteria.Core_Account_Tier__c == '' || FCCriteria.Core_Account_Tier__c.equalsIgnoreCase('null') || FCCriteria.Core_Account_Tier__c.equalsIgnoreCase('any')){
                                tempAccountTier = '<any>';
                            }else{
                                tempAccountTier = FCCriteria.Core_Account_Tier__c.toLowerCase();
                            }
                            
                            if(FCCriteria.Core_Opportunity_Type__c == null || FCCriteria.Core_Opportunity_Type__c == '' || FCCriteria.Core_Opportunity_Type__c.equalsIgnoreCase('null') || FCCriteria.Core_Opportunity_Type__c.equalsIgnoreCase('any')){
                                tempOpportunityType = '<any>';
                            }else{
                                tempOpportunityType = FCCriteria.Core_Opportunity_Type__c.toLowerCase();
                            }
                            FCCommCriteriaMap.put(tempBUShortName.trim()+'_'+tempBUFocus.trim()+'_'+tempAccountTier.trim()+'_'+tempOpportunityType.trim(),FCCriteria);
                        }
                    }
                }
                
                List<Date> qtDateList;
                OpportunityLineItem oppProd;
                String buShortName, opportunityType;
                List<String> bUFocusList, accountTierList;
                Boolean isCommissionable;
                String firstMonth, secondMonth, thirdMonth;
                for(Core_Opp_FC_Prod_Schedule__c forecast : approvedForecastList){
                    if(oppMap.containskey(forecast.Core_Opp_FC_Opportunity__c) && forecast.Core_Opp_FC_Sched_Revenue__c > 0){
                        bUFocusList = new List<String>();
                        bUFocusList.add('<any>');
                        accountTierList = new List<String>();
                        accountTierList.add('<any>');
                        if(test.isRunningTest()){
                            bUFocusList.add('DCG-Cloud');
                            accountTierList.add('DCG-Tier 2');
                            accountTierList.add('DCG-Tier 3');
                        }
                        isCommissionable = false;
                        qtDateList = getMonths(forecast.Core_Opp_FC_Quarter__c);
                        if(qtDateList[0].month() < 10){
                            firstMonth = string.valueOf(0)+qtDateList[0].month()+qtDateList[0].year();
                            secondMonth = string.valueOf(0)+qtDateList[1].month()+qtDateList[1].year();
                            thirdMonth = string.valueOf(0)+qtDateList[2].month()+qtDateList[2].year();
                        }else{
                            firstMonth = ''+qtDateList[0].month()+qtDateList[0].year();
                            secondMonth = ''+qtDateList[1].month()+qtDateList[1].year();
                            thirdMonth = ''+qtDateList[2].month()+qtDateList[2].year();
                        }
                        if(oppProdMap.containskey(forecast.Core_Opp_Line_Item_RecordID__c)){
                            if(oppProdMap.get(forecast.Core_Opp_Line_Item_RecordID__c).Core_BU_Short_Name__c <> null && oppProdMap.get(forecast.Core_Opp_Line_Item_RecordID__c).Core_BU_Short_Name__c <> ''){
                                tempBuShortName = oppProdMap.get(forecast.Core_Opp_Line_Item_RecordID__c).Core_BU_Short_Name__c;
                            }
                        }
                        if(oppMap.get(forecast.Core_Opp_FC_Opportunity__c).Core_Opportunity_Type__c <> null && oppMap.get(forecast.Core_Opp_FC_Opportunity__c).Core_Opportunity_Type__c <> ''){
                            tempOpportunityType = oppMap.get(forecast.Core_Opp_FC_Opportunity__c).Core_Opportunity_Type__c;
                        }
                        if(oppMap.get(forecast.Core_Opp_FC_Opportunity__c).account.Core_Account_BU_Focus__c <> null && oppMap.get(forecast.Core_Opp_FC_Opportunity__c).account.Core_Account_BU_Focus__c <> ''){
                            bUFocusList = oppMap.get(forecast.Core_Opp_FC_Opportunity__c).account.Core_Account_BU_Focus__c.split(';');
                        }
                        if(oppMap.get(forecast.Core_Opp_FC_Opportunity__c).account.Core_Account_Tier__c <> null && oppMap.get(forecast.Core_Opp_FC_Opportunity__c).account.Core_Account_Tier__c <> ''){
                            accountTierList = oppMap.get(forecast.Core_Opp_FC_Opportunity__c).account.Core_Account_Tier__c.split(';');
                        }
                        
                        if(bUFocusList.size() == 1 && accountTierList.size() == 1){
                            productFieldWrapper prodFieldWrap = new productFieldWrapper();
                            prodFieldWrap.BUShortName = tempBuShortName;
                            prodFieldWrap.opportunityType = tempOpportunityType;
                            prodFieldWrap.BUFocus = bUFocusList[0];
                            prodFieldWrap.accountTier = accountTierList[0];
                            isCommissionable = commissionCriteriaCheck(prodFieldWrap,qtDateList[0],FCCommCriteriaMap);
                        }else{
                            for(String buFoc : bUFocusList){
                                for(String accTier : accountTierList){
                                    if(!isCommissionable){
                                        productFieldWrapper prodFieldWrap = new productFieldWrapper();
                                        prodFieldWrap.BUShortName = tempBuShortName;
                                        prodFieldWrap.opportunityType = tempOpportunityType;
                                        prodFieldWrap.BUFocus = buFoc;
                                        prodFieldWrap.accountTier = accTier;
                                        isCommissionable = commissionCriteriaCheck(prodFieldWrap,qtDateList[0],FCCommCriteriaMap);
                                        if(isCommissionable){
                                            break;
                                        }
                                    }
                                }
                            }
                        }
                        
                        if(isCommissionable && oppProdMap.containskey(forecast.Core_Opp_Line_Item_RecordID__c)){
                            for(OpportunityTeamMember oppTeam : oppTeamMap.get(forecast.Core_Opp_FC_Opportunity__c)){
                                if(userMap.get(oppTeam.UserId).Core_Employee_Type_Code__c == 'EMP' && Core_Commissions_Percent_Contribution__c.getInstance(oppTeam.TeamMemberRole) <> null){
                                    trans = new Core_Commissionable_Transaction__c();
                                    trans.Core_Forecast_Product_Schedule__c = forecast.Id;
                                    trans.Core_Approved_Total_Price__c = forecast.Core_Opp_FC_Sched_Revenue__c/3;
                                    trans.Core_Claim_Date__c = qtDateList[0];
                                    trans.Core_Last_Approved_Date__c = qtDateList[0];
                                    trans.Core_Employee_ID__c = oppTeam.UserId;
                                    trans.Core_Employee_Name__c = userMap.get(oppTeam.UserId).Name;
                                    trans.Core_WWID__c = userMap.get(oppTeam.UserId).Core_WWID__c;
                                    trans.Core_Opportunity_Team_Member_Role__c = oppTeam.TeamMemberRole;
                                    trans.Core_Percent_Contribution__c = Core_Commissions_Percent_Contribution__c.getInstance(oppTeam.TeamMemberRole).Core_Percent_Contribution__c;
                                    trans.Core_Source_ID__c = forecast.Core_Opp_Line_Item_RecordID__c+firstMonth;
                                    trans.Core_Transaction_Timestamp__c = System.now();
                                    trans.Core_Account_ID__c = oppMap.get(forecast.Core_Opp_FC_Opportunity__c).AccountId;
                                    trans.Core_Account_Name__c = oppMap.get(forecast.Core_Opp_FC_Opportunity__c).account.Name;
                                   // trans.Core_CIM_ID__c = oppMap.get(forecast.Core_Opp_FC_Opportunity__c).account.Core_CIM_ID__c;
                                    oppProd = oppProdMap.get(forecast.Core_Opp_Line_Item_RecordID__c);
                                    
                                    if(oppProd.Core_Approved_KPI_Product_Group__c != null){
                                        trans.Core_Approved_KPI_Prod_Grp__c = oppProd.Core_Approved_KPI_Product_Group__c;
                                    }
                                    
                                    if(oppProd.CRM_DW_App_UCD_Customer_Name__c!= null){
                                        trans.Core_Approved_Prime_AccountName__c = oppProd.CRM_DW_App_UCD_Customer_Name__c;
                                    }
                                    if(oppProd.Core_Product_Segment__c != null){
                                        trans.Core_Product_Segment__c = oppProd.Core_Product_Segment__c;
                                    }
                                    
                                    if(oppProd.Core_BU_Product_Segment__c!= null){
                                        trans.Core_Approved_BU_Product_Segment__c = oppProd.Core_BU_Product_Segment__c;
                                    }
                                    if(oppProd.Core_Opp_Approved_Sales_Group__c != null){
                                        trans.Core_Approved_Sales_Group__c = oppProd.Core_Opp_Approved_Sales_Group__c;
                                    }
                                    trans.Core_Product2_ID__c = oppProd.Product2Id;
                                    trans.Core_Product_Type__c = oppProd.Core_Product_Type__c;
                                    
                                    trans.Core_Status__c = Label.Core_Commissionable_Transaction_Approved_Status;
                                    trans.Core_Opportunity__c = oppProd.OpportunityId;
                                    trans.Core_Opportunity_Name__c = oppMap.get(oppProd.OpportunityId).Name;
                                    trans.Core_Opportunity_Type__c = oppMap.get(oppProd.OpportunityId).Core_Opportunity_Type__c;
                                    
                                    trans.Core_Transaction_Type__c = 'Consumption Revenue';
                                    
                                    trans.Core_Approved_BU_Short_Name__c = oppProd.Core_BU_Short_Name__c;
                                    commTransList.add(trans);
                                    
                                    Core_Commissionable_Transaction__c transac1 = trans.clone(false, false, false, false);
                                    transac1.Core_Claim_Date__c = qtDateList[1];
                                    transac1.Core_Last_Approved_Date__c = qtDateList[1];
                                    transac1.Core_Source_ID__c = forecast.Core_Opp_Line_Item_RecordID__c+secondMonth;
                                    commTransList.add(transac1);
                                    
                                    Core_Commissionable_Transaction__c transac2 = trans.clone(false, false, false, false);
                                    transac2.Core_Claim_Date__c = qtDateList[2];
                                    transac2.Core_Last_Approved_Date__c = qtDateList[2];
                                    transac2.Core_Source_ID__c = forecast.Core_Opp_Line_Item_RecordID__c+thirdMonth;
                                    commTransList.add(transac2);
                                }
                            }
                        }
                    }
                }
            }
            
            if(!recalledForecastList.isEmpty()){
                List<Core_Commissionable_Transaction__c> transList = [select Id, Core_Forecast_Product_Schedule__c, Core_Approved_Total_Price__c, Core_Claim_Date__c, Core_Employee_ID__c, Core_Employee_Name__c, Core_WWID__c, Core_Opportunity_Team_Member_Role__c, Core_Percent_Contribution__c, Core_Source_ID__c, Core_Transaction_Timestamp__c, Core_Account_ID__c, Core_Account_Name__c , Core_Approved_KPI_Prod_Grp__c, Core_Product_Segment__c, Core_Approved_BU_Product_Segment__c, Core_Approved_Sales_Group__c, Core_Product2_ID__c, Core_Product_Type__c, Core_Status__c, Core_Opportunity__c, Core_Opportunity_Name__c, Core_Opportunity_Type__c, Core_Transaction_Type__c, Core_Approved_BU_Short_Name__c, Core_Last_Approved_Date__c from Core_Commissionable_Transaction__c where Core_Forecast_Product_Schedule__c IN: recalledForecastList order by createdDate desc];
                if(!transList.isEmpty() && transList[0].Core_Status__c.equalsIgnoreCase('Approved')){
                    for(Integer i = 0; i<transList.size(); i++){
                        if(transList[i].Core_Status__c.equalsIgnoreCase('Approved')){
                            trans = new Core_Commissionable_Transaction__c();
                            trans = transList[i].clone();
                            trans.Core_Status__c = 'Pending';
                            trans.Core_Approved_Total_Price__c = transList[i].Core_Approved_Total_Price__c;
                            trans.Core_Transaction_Timestamp__c = System.now();
                            commTransList.add(trans);
                        }else{
                            i = transList.size();
                        }
                    }
                }
            }
            
            if(!commTransList.isEmpty()){
                insert commTransList;
            }
        }catch(Exception e){
            Core_Exceptions__c excep = new Core_Exceptions__c();
            excep.Core_Class_Name__c = 'Core_Opp_FC_6QPSHandler';
            excep.Core_Method_Name__c = 'addCommissionableTransaction';
            excep.Core_Record_Id__c = forecastList[0].Id;
            excep.Core_Exception__c = e.getStackTraceString() + ';' + e.getCause() + ';' + e.getMessage();
            excep.Core_IPS_Object_Name__c = 'Core_Opp_FC_Prod_Schedule__c';                                                   
            excep.Core_Login_User_Id__c = userInfo.getUserId();
            insert excep;
        }
    }*/
    
    public static boolean commissionCriteriaCheck(productFieldWrapper prodFieldWrap, Date forecastApprovedDate, Map<String, Core_FC_Commission_Criterias__c> FCCommCriteriaMap){
        boolean isCommissionable = false;
        string commCriteria1 = '<any>'+'_'+'<any>'+'_'+'<any>'+'_'+'<any>';
        string commCriteria2 = prodFieldWrap.BUShortName.trim()+'_'+'<any>'+'_'+'<any>'+'_'+'<any>';
        string commCriteria3 = prodFieldWrap.BUShortName.trim()+'_'+prodFieldWrap.BUFocus.trim()+'_'+'<any>'+'_'+'<any>';
        string commCriteria4 = prodFieldWrap.BUShortName.trim()+'_'+prodFieldWrap.BUFocus.trim()+'_'+prodFieldWrap.accountTier.trim()+'_'+'<any>';
        string commCriteria5 = prodFieldWrap.BUShortName.trim()+'_'+prodFieldWrap.BUFocus.trim()+'_'+'<any>'+'_'+prodFieldWrap.opportunityType.trim();
        string commCriteria6 = prodFieldWrap.BUShortName.trim()+'_'+prodFieldWrap.BUFocus.trim()+'_'+prodFieldWrap.accountTier.trim() +'_'+prodFieldWrap.opportunityType.trim();
        string commCriteria7 = prodFieldWrap.BUShortName.trim()+'_'+'<any>'+'_'+prodFieldWrap.accountTier.trim()+'_'+prodFieldWrap.opportunityType.trim();
        string commCriteria8 = prodFieldWrap.BUShortName.trim()+'_'+'<any>'+'_'+prodFieldWrap.accountTier.trim()+'_'+'<any>';
        string commCriteria9 = prodFieldWrap.BUShortName.trim()+'_'+'<any>'+'_'+'<any>'+'_'+prodFieldWrap.opportunityType.trim();
        string commCriteria10 = '<any>'+'_'+'<any>'+'_'+prodFieldWrap.accountTier.trim()+'_'+prodFieldWrap.opportunityType.trim();
        string commCriteria11 = '<any>'+'_'+'<any>'+'_'+prodFieldWrap.accountTier.trim()+'_'+'<any>';
        string commCriteria12 = '<any>'+'_'+'<any>'+'_'+'<any>'+'_'+prodFieldWrap.opportunityType.trim();
        string commCriteria13 = '<any>'+'_'+prodFieldWrap.BUFocus.trim()+'_'+prodFieldWrap.accountTier.trim()+'_'+prodFieldWrap.opportunityType.trim();
        string commCriteria14 = '<any>'+'_'+prodFieldWrap.BUFocus.trim()+'_'+'<any>'+'_'+'<any>';
        string commCriteria15 = '<any>'+'_'+prodFieldWrap.BUFocus.trim()+'_'+prodFieldWrap.accountTier.trim()+'_'+'<any>';
        string commCriteria16 = '<any>'+'_'+prodFieldWrap.BUFocus.trim()+'_'+'<any>'+'_'+prodFieldWrap.opportunityType.trim();
        string finalCommCriteria = '';
        if(FCCommCriteriaMap.containskey(commCriteria1.toLowerCase())){
            finalCommCriteria = commCriteria1.toLowerCase();
        }else if(FCCommCriteriaMap.containskey(commCriteria2.toLowerCase())){
            finalCommCriteria = commCriteria2.toLowerCase();
        }else if(FCCommCriteriaMap.containskey(commCriteria3.toLowerCase())){
            finalCommCriteria = commCriteria3.toLowerCase();
        }else if(FCCommCriteriaMap.containskey(commCriteria4.toLowerCase())){
            finalCommCriteria = commCriteria4.toLowerCase();
        }else if(FCCommCriteriaMap.containskey(commCriteria5.toLowerCase())){
            finalCommCriteria = commCriteria5.toLowerCase();
        }else if(FCCommCriteriaMap.containskey(commCriteria6.toLowerCase())){
            finalCommCriteria = commCriteria6.toLowerCase();
        }else if(FCCommCriteriaMap.containskey(commCriteria7.toLowerCase())){
            finalCommCriteria = commCriteria7.toLowerCase();
        }else if(FCCommCriteriaMap.containskey(commCriteria8.toLowerCase())){
            finalCommCriteria = commCriteria8.toLowerCase();
        }else if(FCCommCriteriaMap.containskey(commCriteria9.toLowerCase())){
            finalCommCriteria = commCriteria9.toLowerCase();
        }else if(FCCommCriteriaMap.containskey(commCriteria10.toLowerCase())){
            finalCommCriteria = commCriteria10.toLowerCase();
        }else if(FCCommCriteriaMap.containskey(commCriteria11.toLowerCase())){
            finalCommCriteria = commCriteria11.toLowerCase();
        }else if(FCCommCriteriaMap.containskey(commCriteria12.toLowerCase())){
            finalCommCriteria = commCriteria12.toLowerCase();
        }else if(FCCommCriteriaMap.containskey(commCriteria13.toLowerCase())){
            finalCommCriteria = commCriteria13.toLowerCase();
        }else if(FCCommCriteriaMap.containskey(commCriteria14.toLowerCase())){
            finalCommCriteria = commCriteria14.toLowerCase();
        }else if(FCCommCriteriaMap.containskey(commCriteria15.toLowerCase())){
            finalCommCriteria = commCriteria15.toLowerCase();
        }else if(FCCommCriteriaMap.containskey(commCriteria16.toLowerCase())){
            finalCommCriteria = commCriteria16.toLowerCase();
        }
        //system.debug('finalCommCriteria '+finalCommCriteria);
        if(finalCommCriteria <> '' && forecastApprovedDate >= FCCommCriteriaMap.get(finalCommCriteria).Core_Schedule_Quarter_Start_Date__c && forecastApprovedDate <= FCCommCriteriaMap.get(finalCommCriteria).Core_Schedule_Quarter_End_Date__c){
            isCommissionable = true;
        }
        return isCommissionable;
    }
    
    /*
    *Method Name: getMonths
    *Parameters: String quarterName
    *Description: This method is to calculate list of months as per quarter.
    */
    public static List<Date> getMonths(String quarterName){
        List<Date> monthList = new List<Date>();
        List<String> qtList = quarterName.split('-Q');
        if(Integer.valueOf(qtList[1]) == 1){
            monthList.add(date.newInstance(Integer.valueOf(qtList[0]), 01, 10));
            monthList.add(date.newInstance(Integer.valueOf(qtList[0]), 02, 10));
            monthList.add(date.newInstance(Integer.valueOf(qtList[0]), 03, 10));
        }else if(Integer.valueOf(qtList[1]) == 2){
            monthList.add(date.newInstance(Integer.valueOf(qtList[0]), 04, 10));
            monthList.add(date.newInstance(Integer.valueOf(qtList[0]), 05, 10));
            monthList.add(date.newInstance(Integer.valueOf(qtList[0]), 06, 10));
        }else if(Integer.valueOf(qtList[1]) == 3){
            monthList.add(date.newInstance(Integer.valueOf(qtList[0]), 07, 10));
            monthList.add(date.newInstance(Integer.valueOf(qtList[0]), 08, 10));
            monthList.add(date.newInstance(Integer.valueOf(qtList[0]), 09, 10));
        }else{
            monthList.add(date.newInstance(Integer.valueOf(qtList[0]), 10, 10));
            monthList.add(date.newInstance(Integer.valueOf(qtList[0]), 11, 10));
            monthList.add(date.newInstance(Integer.valueOf(qtList[0]), 12, 10));
        }
        return monthList;
    }
    
    public class productFieldWrapper{
        public String BUShortName, BUFocus, accountTier, opportunityType;
        public productFieldWrapper(){
            BUShortName = BUFocus = accountTier = opportunityType = '<any>';
        }
    }
}