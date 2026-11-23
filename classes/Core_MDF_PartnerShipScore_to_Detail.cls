public without sharing class Core_MDF_PartnerShipScore_to_Detail {
    public static set<String> Programs_For_Node_Account = Core_MDF_CCP_ConstantClass.Programs_For_Node_Account;    
    public static final set<id> AccountId = new set<id>();
    public static final Set<String>Program = new set<string>();
    public static final Set<String> psprevScoreIdList = new set<string>();
    public static Map<String, Boolean> psKeyToPettyRuleMap = new Map<String, Boolean>();
    public static Set<String> psdKeyWithCurrentQuarter = new Set<String>();

    public static void Executedata(List<Core_MDF_Partnership_Score__c> PSList,String program,String Quarter,String accounts) {
        String quartertoQuery = Quarter;
        Map<string, List<Core_MDF_Partnership_Score__c>> res = new Map<string, List<Core_MDF_Partnership_Score__c>>();
        Map<string, List<Core_MDF_Scorecard__c>> res1 = new Map<string, List<Core_MDF_Scorecard__c>>();
        Map<string, List<Core_MDF_PartnerResponseZone__c>> res3 = new Map<string, List<Core_MDF_PartnerResponseZone__c>>();
        Map<String, List<Core_MDF_Partnership_Score_Detail__c >> res4 =  new Map<String, List<Core_MDF_Partnership_Score_Detail__c >>();
         try{
        res = getPartnershipScoreData(PSList,quartertoQuery);
        res3 = getValuesbasedonZones();
        res1= getScoreCardData(quartertoQuery,res,program, accounts, res3);
        res4 =getValuesfromdetailforCarryFwd(program, accounts, quartertoQuery);
        doScoreCardDataCalculations(res1,res,res3,res4,Quarter);
         }
        
          catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
    }

     public static Map<string, List<Core_MDF_Partnership_Score__c>> getPartnershipScoreData(List<Core_MDF_Partnership_Score__c> PSList,String Quarter){
          List<Core_MDF_Partnership_Score__c> PScoreList;
          Map<string, List<Core_MDF_Partnership_Score__c>> prgmAccQuarterYearToPScoreMap = new Map<string,List<Core_MDF_Partnership_Score__c>>();
          try{
            for(Core_MDF_Partnership_Score__c rec: PSList) {
                                                    string key = rec.Core_MDF_Program_nm__c + rec.Core_MDF_Virtual_Corp_Account_Id__c +rec.Core_MDF_Quarter_Year_Nm__c;
                                                    PScoreList = prgmAccQuarterYearToPscoreMap.get(key) == null? new List<Core_MDF_Partnership_Score__c>() : prgmAccQuarterYearToPscoreMap.get(key);
                                                    if(rec.Core_MDF_Zone_nm__c!=null && rec.Core_MDF_Quarter_Year_Nm__c!=null) {
                                                        PScoreList.add(rec);
                                                        prgmAccQuarterYearToPScoreMap.put(key,PScoreList);
                                                        AccountId.add(rec.Core_MDF_Account_Id__r.Id);
                                                        Program.add(rec.Core_MDF_Program_nm__c);
                                                         if(String.isNotBlank(rec.Core_MDF_Partnership_Score_Id__c)&&String.isNotEmpty(rec.Core_MDF_Partnership_Score_Id__c)&&rec.Core_MDF_Partnership_Score_Id__c!=null){
                                                            psprevScoreIdList.add(rec.Core_MDF_Partnership_Score_Id__c);
                                                        }
                                                    }
                                                   
                                                    
            }
              
                                              
     }
         catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
         return prgmAccQuarterYearToPScoreMap;
}
    public static Map<String, List<Core_MDF_Scorecard__c>> getScoreCardData(String quarter, Map<string, List<Core_MDF_Partnership_Score__c>> pSMap,String program,String accounts, Map<string, List<Core_MDF_PartnerResponseZone__c>> zoneToRecordsMap ){
        Map<Id, List<Core_MDF_Scorecard__c >> pScoretoScoreCardMap = new Map<Id, List<Core_MDF_Scorecard__c >> ();
        Map<string, List<Core_MDF_Scorecard__c>> prgmAccQuarterYearToScoreCardMap = new Map<string,List<Core_MDF_Scorecard__c>>();
        Map<String, List<Core_MDF_Scorecard__c>> psKeyToScoreCardsMap = new Map<String, List<Core_MDF_Scorecard__c>>();
        List<Core_MDF_Scorecard__c> scoreCardList;
        String matchwithPartnershipScoreCardKey;
        //Swati - exclude RSA MD         
        String RSA_MDbudget = Core_MDF_CCP_ConstantClass.RMF_RSA_MD_BUDGET_TYPE;
        Date excludeDate = Date.valueOf(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Exclude_RSA_MD'));

        try{
            String query1 = 'select id,Core_MDF_Score_Nbr__c,Core_MDF_Case_Id__r.Core_MDF_Budget_Type_nm__c,Core_MDF_Case_Id__r.Core_MDF_Region_SubRegion_txt__c,Core_MDF_Case_Id__r.Core_Account_Geo__c,Core_MDF_Manual_Recovery_Amount_USD_Amt__c,Core_MDF_Claim_Amt__c,Core_MDF_Case_Id__r.Core_MDF_Channel_Program_txt__c, Core_MDF_Case_Id__r.Account.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c, Core_MDF_Case_Id__r.AccountId,Core_MDF_Case_Id__r.Account.Core_MDF_CoMarketing_Ultimate_Account__r.name,Core_MDF_Quarter__c, Core_MDF_Case_Id__r.Account.Core_MDF_Virtual_Corp_Account_Id__c,Core_MDF_Virtual_Corp_Account_Id__c,Core_MDF_Case_Id__r.ClosedDate FROM Core_MDF_Scorecard__c where Core_MDF_Case_Id__r.Core_MDF_Status__c =\'Review Completed\' AND Core_MDF_Score_Nbr__c <> null AND ( Core_MDF_Case_Id__r.Core_MDF_Budget_Type_nm__c != :RSA_MDbudget OR ( Core_MDF_Case_Id__r.Core_MDF_Budget_Type_nm__c = :RSA_MDbudget AND DAY_ONLY(Core_MDF_Case_Id__r.ClosedDate) <= :excludeDate ))';
            String query2 = '';
            if(!String.isBlank(program)){
                //string pgm = program.replace('-' , '');
                query2 = ' AND Core_MDF_Case_Id__r.Core_MDF_Channel_Program_txt__c=:program ';
            }
            if(!String.isBlank(accounts)){
                List<String> accountIdList = accounts.split(',');
                query2 += 'AND Core_MDF_Case_Id__r.Account.Core_MDF_CoMarketing_Ultimate_Account__r.Id IN: accountIdList';
            }
            if(!String.isBlank(quarter)){
                query2 += ' AND Core_MDF_Quarter__c=:quarter ';
            }
            //Add in query closeddate <= april 1 and budget type =RSA MD
            for(Core_MDF_Scorecard__c scoreCardRec: Database.query(query1+query2)) {
                
               /* //Swati-Added to Skip PSD/RD creation for RMF when budget is RSA MD starting Q2 2026
                Boolean isRetailMarketingFunds = scoreCardRec.Core_MDF_Case_Id__r.Core_MDF_Channel_Program_txt__c == Core_MDF_CCP_ConstantClass.RMF_PROGRAM;
                Boolean isBudgetRsaMd = scoreCardRec.Core_MDF_Case_Id__r.Core_MDF_Budget_Type_nm__c == Core_MDF_CCP_ConstantClass.RMF_RSA_MD_BUDGET_TYPE;
                Boolean iscaseClosedDate = (scoreCardRec.Core_MDF_Case_Id__r.ClosedDate.date() >= Date.valueOf(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Exclude_RSA_MD')));
                Boolean skipRSA_MD = isRetailMarketingFunds && isBudgetRsaMd && iscaseClosedDate;
                
                if (skipRSA_MD) {
                    // Skip creating PSD/RD for RMF when budget is RSA MD starting Q2 2026 
                    continue;
                }//END -Swati*/
                String technicalProgramName = scoreCardRec.Core_MDF_Case_Id__r.Account.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c;
                Boolean addNodeAccoutKey = Programs_For_Node_Account.contains(scoreCardRec.Core_MDF_Case_Id__r.Core_MDF_Channel_Program_txt__c) ? true : false;
                matchwithPartnershipScoreCardKey = technicalProgramName + scoreCardRec.Core_MDF_Virtual_Corp_Account_Id__c + scoreCardRec.Core_MDF_Quarter__c;       
                string scoreCardkey = technicalProgramName + scoreCardRec.Core_MDF_Virtual_Corp_Account_Id__c + scoreCardRec.Core_MDF_Quarter__c + ';' + (addNodeAccoutKey ? scoreCardRec.Core_MDF_Case_Id__r.AccountId + ',' : '') + scoreCardRec.Core_MDF_Case_Id__r.Core_MDF_Budget_Type_nm__c+','+scoreCardRec.Core_MDF_Case_Id__r.Core_MDF_Region_SubRegion_txt__c.split('-')[0].trim();
                
                scoreCardList = prgmAccQuarterYearToScoreCardMap.get(scoreCardkey) == null? new List<Core_MDF_Scorecard__c>() : prgmAccQuarterYearToScoreCardMap.get(scoreCardkey);
                scoreCardList.add(scoreCardRec);
                system.debug(matchwithPartnershipScoreCardKey);
                if(pSMap.containsKey(matchwithPartnershipScoreCardKey)) {
                    prgmAccQuarterYearToScoreCardMap.put(scoreCardkey,scoreCardList);
                    if(!psKeyToScoreCardsMap.containsKey(matchwithPartnershipScoreCardKey)) {
                        psKeyToScoreCardsMap.put(matchwithPartnershipScoreCardKey, new List<Core_MDF_Scorecard__c>{scoreCardRec});
                    }else {
                        psKeyToScoreCardsMap.get(matchwithPartnershipScoreCardKey).add(scoreCardRec);
                    }
                }
            }
            
            for(String parternshipScoreKey : psKeyToScoreCardsMap.keySet()) {
                List<Core_MDF_Scorecard__c> scList = new List<Core_MDF_Scorecard__c>();
                Decimal recAmt_PV1 = 0.0; 
                Decimal recAmt_PV2 = 0.0; 
                Decimal recAmt_PV4 = 0.0;
                Decimal totalAmtPettyRule = 0.0;
                Decimal totalClaimAmt = 0.0;

                Core_MDF_PartnerResponseZone__c zonePercentageDetail = (pSMap.containsKey(parternshipScoreKey) && zoneToRecordsMap.containsKey(pSMap.get(parternshipScoreKey)[0].Core_MDF_Zone_nm__c)) ? zoneToRecordsMap.get(pSMap.get(parternshipScoreKey)[0].Core_MDF_Zone_nm__c)[0] : new Core_MDF_PartnerResponseZone__c();
                
                if(zonePercentageDetail != null) {
                    scList = psKeyToScoreCardsMap.get(parternshipScoreKey);
                    
                    for(Core_MDF_Scorecard__c sc : scList) { //Calculate the Recovery Amounts
                        
                        totalClaimAmt = totalClaimAmt + sc.Core_MDF_Claim_Amt__c;
                        
                        if(sc.Core_MDF_Score_Nbr__c == 1) {
                            recAmt_PV1 = recAmt_PV1 + sc.Core_MDF_Claim_Amt__c ;
                        }
                        if(sc.Core_MDF_Score_Nbr__c == 2) {
                            recAmt_PV2 = recAmt_PV2 + sc.Core_MDF_Claim_Amt__c ;
                        }
                        if(sc.Core_MDF_Score_Nbr__c == 4) {
                            recAmt_PV4 = recAmt_PV4 + sc.Core_MDF_Claim_Amt__c;
                        }
                    }

                    totalAmtPettyRule =  recAmt_PV1 * (zonePercentageDetail.Core_MDF_PV1_Percent_Recovery__c/100) + recAmt_PV2 * (zonePercentageDetail.Core_MDF_PV2_Percent_Recovery__c/100) + recAmt_PV4 * (zonePercentageDetail.Core_MDF_PV4_Percent_Recovery__c/100);
                    //Check for Petty rule for a Partership Score
                    if(totalAmtPettyRule < totalClaimAmt / 1000) {
                        psKeyToPettyRuleMap.put(parternshipScoreKey, true);
                    }else {
                        psKeyToPettyRuleMap.put(parternshipScoreKey, false);
                    }
                }
            }                                    
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
        return prgmAccQuarterYearToScoreCardMap;
        
    
}
     public static Map<string, List<Core_MDF_PartnerResponseZone__c>> getValuesbasedonZones(){
        Map<String, List<Core_MDF_PartnerResponseZone__c >> pScoretoScoreCardMap = new Map<String, List<Core_MDF_PartnerResponseZone__c >> ();
        String Zone;
        Decimal ZV;
        Decimal PV1;Decimal PV2;Decimal PV4;
        List<Core_MDF_PartnerResponseZone__c> pzrecList;
         try{
        for(Core_MDF_PartnerResponseZone__c pzrec: [Select Core_MDF_Zone_Nm__c, Core_MDF_ZV_Percent_Recovery__c,Core_MDF_PV1_Percent_Recovery__c,Core_MDF_PV2_Percent_Recovery__c,Core_MDF_PV4_Percent_Recovery__c
                                                                    FROM Core_MDF_PartnerResponseZone__c order by Core_MDF_Zone_Nm__c Limit 1000 ]
           ) {
               string Zone_Nm = pzrec.Core_MDF_Zone_Nm__c;
               pzrecList = pScoretoScoreCardMap.get(Zone_Nm) == null? new List<Core_MDF_PartnerResponseZone__c>() : pScoretoScoreCardMap.get(Zone_Nm);
               pzrecList.add(pzrec);
               pScoretoScoreCardMap.put(Zone_Nm,pzrecList);
               
           }
             
         }
         catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
         return pScoretoScoreCardMap;
        
     }
    
     public static Map<string, List<Core_MDF_Partnership_Score_Detail__c>> getValuesfromdetailforCarryFwd(String program,String accountIds,String quarter){
        Map<String, List<Core_MDF_Partnership_Score_Detail__c >> pScoretodetail = new Map<String, List<Core_MDF_Partnership_Score_Detail__c >> ();
        List<Core_MDF_Partnership_Score_Detail__c> pgdList;
        String qtrforCarryfwdAmt;
        String qtrforprevQtr;
        if(String.isNotBlank(quarter)){   
            qtrforprevQtr = quarter;    
            List<String> qysplit = quarter.split(' ');
            List<String> qsplit = qysplit[0].split('');
            Integer quarterInteger = integer.valueof(qsplit[1]);
            Integer yearInteger = integer.valueof(qysplit[1]);
            yearInteger = (quarterInteger==1)?yearInteger-1:yearInteger;
            quarterInteger = (quarterInteger==1)?4:quarterInteger-1;
            qtrforCarryfwdAmt = 'Q'+quarterInteger+' '+yearInteger;
        }
        try{
            String query1 ='Select Id,Core_MDF_Program_Nm__c, Core_MDF_Partnership_Score_Id__r.Core_MDF_Program_nm__c, Core_MDF_Account_Id__c,Core_MDF_External_Id__c, Core_MDF_Node_Account_Id__c, Core_MDF_Balance_Amount_Amt__c,Core_MDF_Budget_Type_Nm__c,Core_MDF_Region_Cd__c,Core_MDF_Quarter_Year_Nm__c,Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c,Core_MDF_Partnership_Score_Id__r.Core_MDF_Channel_Program_Id__c, Core_MDF_Partnership_Score_Id__r.Core_MDF_Virtual_Corp_Account_Id__c FROM Core_MDF_Partnership_Score_Detail__c Where ((Core_MDF_Quarter_Year_Nm__c =: qtrforCarryfwdAmt and Core_MDF_Partnership_Score_Id__c IN: psprevScoreIdList) OR (Core_MDF_Quarter_Year_Nm__c =: quarter AND Core_MDF_Partnership_Score_Detail_Id__c = null)) AND Core_MDF_Region_Cd__c != null';
            String query2 = '';
            if(!String.isBlank(program)){
                //string pgm = program.replace('-' , '');
                query2 = ' AND Core_MDF_Program_Nm__c=:program';
            }
            if(!String.isBlank(accountIds)){
                List<String> accountIdList = accountIds.split(',');
                query2 += ' AND Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c IN:accountIdList';
            }
        for(Core_MDF_Partnership_Score_Detail__c psdrec:Database.query(query1+query2)) {
                Boolean addNodeAccoutKey = Programs_For_Node_Account.contains(psdrec.Core_MDF_Program_Nm__c) && String.isNotBlank(psdrec.Core_MDF_Node_Account_Id__c) ? true : false;
                //String technicalProgramName = Core_MDF_CCP_GenericUtility.getTechnicalProgramName(psdrec.Core_MDF_Program_Nm__c);
                string ExtIdKey = psdrec.Core_MDF_Partnership_Score_Id__r.Core_MDF_Program_nm__c + psdrec.Core_MDF_Partnership_Score_Id__r.Core_MDF_Virtual_Corp_Account_Id__c + psdrec.Core_MDF_Quarter_Year_Nm__c + (addNodeAccoutKey ? String.valueOf(psdrec.Core_MDF_Node_Account_Id__c) : '') + psdrec.Core_MDF_Budget_Type_Nm__c+psdrec.Core_MDF_Region_Cd__c;
            
            if(ExtIdKey !=null){
               pgdList = pScoretodetail.get(ExtIdKey) == null? new List<Core_MDF_Partnership_Score_Detail__c>() : pScoretodetail.get(ExtIdKey);
               pgdList.add(psdrec);
               ExtIdKey = ExtIdKey.replace(qtrforCarryfwdAmt,qtrforprevQtr);
                
               pScoretodetail.put(ExtIdKey,pgdList);
               
               if(psdrec.Core_MDF_Quarter_Year_Nm__c == quarter){
                    psdKeyWithCurrentQuarter.add(ExtIdKey);
               }
            }
               
           }
             
         }
         catch(exception ex){
             
             Core_MDF_CCP_UtilityClass.logError(ex);}
         return pScoretodetail;
        
     }
    
    
   
    public static void doScoreCardDataCalculations(Map<string, List<Core_MDF_Scorecard__c>> prgmAccQuarterYearToScoreCardMap, Map<string, List<Core_MDF_Partnership_Score__c>> prgmAccQuarterYearToPScoreMap, Map<String, List<Core_MDF_PartnerResponseZone__c>> pScoretoScoreCardMap,Map<String, List<Core_MDF_Partnership_Score_Detail__c >> pScoretodetail, String Quarter){
        String Zone;     
        Decimal ZV;
        Decimal PV1;Decimal PV2;Decimal PV4;
        Id id_PScore;
        String Budgettype;
        String Geo;
        String nodeAccountId;
        List<Core_MDF_Partnership_Score_Detail__c> pgdRecToBeInserted = new List<Core_MDF_Partnership_Score_Detail__c >();
        try{
        Set<String> sckeyset = new Set<String>();
        Set<String> prevkeyset = new Set<String>();
       
        
        for (string Key :prgmAccQuarterYearToScoreCardMap.Keyset())
        {
            String[] KeytomatchPartnershipScore = Key.split(';');
            String budgettypegeo =KeytomatchPartnershipScore[1];
            string[] splitbudgettypegeo =budgettypegeo.split(',');
          
           
            /*Budgettype=splitbudgettypegeo[0];
            if (Budgettype == 'null')
            {
            
                Budgettype = ' ';
            }
            Geo=splitbudgettypegeo[1];*/


            if(splitbudgettypegeo.size() == 3){ //Only for IPA and RMF to map Node AccountId
                nodeAccountId = splitbudgettypegeo[0];
                Budgettype = splitbudgettypegeo[1] == 'null' ? 'null' : splitbudgettypegeo[1];
                Geo = splitbudgettypegeo[2];
            }else if(splitbudgettypegeo.size() == 2){
                nodeAccountId = null;
                Budgettype = splitbudgettypegeo[0] == 'null' ? 'null' : splitbudgettypegeo[0];
                Geo = splitbudgettypegeo[1];
            }

            String KeytomatchPartnershipScoreDetail = Key.replace(';','');
            List<Core_MDF_Partnership_Score__c> pscoreList = prgmAccQuarterYearToPScoreMap.get(KeytomatchPartnershipScore[0]);//Get the Zone Name
            List<Core_MDF_Partnership_Score_Detail__c>CFAmtToBeInserted = pScoretodetail.get(KeytomatchPartnershipScoreDetail.replace(',',''));
            sckeyset.add(KeytomatchPartnershipScoreDetail.replace(',',''));
            List<Core_MDF_Scorecard__c> scList = new List<Core_MDF_Scorecard__c>();
            if(pscoreList!=null)
            {
             Zone = pscoreList[0].Core_MDF_Zone_nm__c;
             id_PScore = pscoreList[0].id;
             scList = prgmAccQuarterYearToScoreCardMap.get(Key);
            }
            List<Core_MDF_PartnerResponseZone__c> Zone_data = pScoretoScoreCardMap.get(Zone);//Get the zone 
            if(Zone_data!=null && pscoreList!=null)
            {
            ZV = Zone_data[0].Core_MDF_ZV_Percent_Recovery__c;
            PV1= Zone_data[0].Core_MDF_PV1_Percent_Recovery__c;
            PV2= Zone_data[0].Core_MDF_PV2_Percent_Recovery__c;
            PV4= Zone_data[0].Core_MDF_PV4_Percent_Recovery__c;
            }
            Decimal recAmt = 0.0;
            Decimal recAmt_PV0 = 0.0;Decimal recAmt_PV1 = 0.0;Decimal recAmt_PV2 = 0.0;Decimal recAmt_PV4 = 0.0;
            Decimal ManrecAmt_PV0 = 0.0;Decimal ManrecAmt_PV1 = 0.0;Decimal ManrecAmt_PV2 = 0.0;Decimal ManrecAmt_PV4 = 0.0;Decimal ManrecAmt_PV8 = 0.0;
            Decimal totalAmtPettyRule = 0.0;
            Decimal totalClaimAmt = 0.0;
            List<Core_MDF_Bulk_Transaction__e> toBeUpdated = new List<Core_MDF_Bulk_Transaction__e>();
            Core_MDF_Partnership_Score_Detail__c  pgd = new Core_MDF_Partnership_Score_Detail__c ();
            if(scList!=null && pscoreList!=null){
            for(Core_MDF_Scorecard__c sc :scList) //Calculate the Recovery Amounts
            {
                totalClaimAmt = totalClaimAmt + sc.Core_MDF_Claim_Amt__c;
                
                if(sc.Core_MDF_Score_Nbr__c == 0){
                    recAmt_PV0 = recAmt_PV0 + sc.Core_MDF_Claim_Amt__c;
                   // ManrecAmt_PV0 = ManrecAmt_PV0 +(sc.Core_MDF_Manual_Recovery_Amount_USD_Amt__c == null ? 0 : sc.Core_MDF_Manual_Recovery_Amount_USD_Amt__c);
                } 
                if(sc.Core_MDF_Score_Nbr__c == 1){
                    recAmt_PV1 = recAmt_PV1 + sc.Core_MDF_Claim_Amt__c ;
                    ManrecAmt_PV1 = ManrecAmt_PV1+(sc.Core_MDF_Manual_Recovery_Amount_USD_Amt__c == null ? 0 : sc.Core_MDF_Manual_Recovery_Amount_USD_Amt__c);
                }
                if(sc.Core_MDF_Score_Nbr__c == 2){
                    recAmt_PV2 = recAmt_PV2 + sc.Core_MDF_Claim_Amt__c ;
                    ManrecAmt_PV2=ManrecAmt_PV2+(sc.Core_MDF_Manual_Recovery_Amount_USD_Amt__c == null ? 0 : sc.Core_MDF_Manual_Recovery_Amount_USD_Amt__c);
                }
                if(sc.Core_MDF_Score_Nbr__c == 4){
                    recAmt_PV4 = recAmt_PV4 + sc.Core_MDF_Claim_Amt__c;
                    ManrecAmt_PV4 = ManrecAmt_PV4 +(sc.Core_MDF_Manual_Recovery_Amount_USD_Amt__c == null ? 0 : sc.Core_MDF_Manual_Recovery_Amount_USD_Amt__c);
                }
                if (sc.Core_MDF_Score_Nbr__c == 8){
                     ManrecAmt_PV8 = ManrecAmt_PV8 +(sc.Core_MDF_Manual_Recovery_Amount_USD_Amt__c == null ? 0 : sc.Core_MDF_Manual_Recovery_Amount_USD_Amt__c);
                }
                
            }
                Decimal recAmtTemp = 0.0;
                recAmtTemp = (recAmt_PV0+ManrecAmt_PV0)+((recAmt_PV1*(PV1/100))+ManrecAmt_PV1)+((recAmt_PV2*(PV2/100))+ManrecAmt_PV2)+((recAmt_PV4*(PV4/100))+ManrecAmt_PV4)+ManrecAmt_PV8;
                //totalAmtPettyRule - the amount to be checked against total ClaimedAmount's 0.1%
                
                totalAmtPettyRule =  recAmt_PV1*(PV1/100) + recAmt_PV2*(PV2/100) + recAmt_PV4*(PV4/100);
                if(psKeyToPettyRuleMap.containsKey(KeytomatchPartnershipScore[0]) && psKeyToPettyRuleMap.get(KeytomatchPartnershipScore[0])){
                    recAmt = recAmtTemp - totalAmtPettyRule;
                    //recAmt = recAmt_PV0+ManrecAmt_PV0 + ManrecAmt_PV1+ManrecAmt_PV2+ManrecAmt_PV4+ManrecAmt_PV8;
                }else{
                    recAmt = recAmtTemp;
                    //recAmt =  (recAmt_PV0+ManrecAmt_PV0)+((recAmt_PV1*(PV1/100))+ManrecAmt_PV1)+((recAmt_PV2*(PV2/100))+ManrecAmt_PV2)+((recAmt_PV4*(PV4/100))+ManrecAmt_PV4)+ManrecAmt_PV8;
                }               
               pgd.Core_MDF_Partnership_Score_Id__c=id_PScore;
               pgd.Core_MDF_External_Id__c=String.valueOf(pscoreList[0].Core_MDF_Channel_Program_Id__c) + String.valueOf(pscoreList[0].Core_MDF_Virtual_Corp_Account_Id__c) + String.valueOf(pscoreList[0].Core_MDF_Quarter_Year_Nm__c) + (String.isNotBlank(nodeAccountId) ? nodeAccountId : '') + Budgettype + Geo;
               if(CFAmtToBeInserted!=null && pscoreList!=null){
                    Core_MDF_Partnership_Score_Detail__c psdrec = CFAmtToBeInserted[0];
                    Boolean addNodeAccoutKey = Programs_For_Node_Account.contains(psdrec.Core_MDF_Program_Nm__c) && String.isNotBlank(psdrec.Core_MDF_Node_Account_Id__c) ? true : false;
                    //String technicalProgramName = Core_MDF_CCP_GenericUtility.getTechnicalProgramName(psdrec.Core_MDF_Program_Nm__c);
                    string extIdKey = psdrec.Core_MDF_Partnership_Score_Id__r.Core_MDF_Program_nm__c +psdrec.Core_MDF_Partnership_Score_Id__r.Core_MDF_Virtual_Corp_Account_Id__c + psdrec.Core_MDF_Quarter_Year_Nm__c + (addNodeAccoutKey ? String.valueOf(psdrec.Core_MDF_Node_Account_Id__c) : '') + psdrec.Core_MDF_Budget_Type_Nm__c+psdrec.Core_MDF_Region_Cd__c;
                    if(!psdKeyWithCurrentQuarter.contains(extIdKey)){
                        pgd.Core_MDF_Carry_Over_Amt__c = CFAmtToBeInserted[0].Core_MDF_Balance_Amount_Amt__c;
                        pgd.Core_MDF_Partnership_Score_Detail_Id__c = CFAmtToBeInserted[0].Id;
                    }
               }
               pgd.Core_MDF_Region_Cd__c = Geo;
              
               pgd.Core_MDF_Budget_Type_nm__c = Budgettype;
               pgd.Core_MDF_Node_Account_Id__c = nodeAccountId;
             
                
            }
               if (pgd!=null && pscoreList!=null)// && pgdRecToBeInserted.size()<100)
                {
                pgdRecToBeInserted.add(pgd);
                }                
        }
        
        String qtrforprevQtr = Quarter; 
        for(String key:pScoretodetail.keyset()){
            if(!sckeyset.contains(key)){
                //String technicalProgramName = Core_MDF_CCP_GenericUtility.getTechnicalProgramName(pScoretodetail.get(key)[0].Core_MDF_Program_Nm__c);
                String keyForPS= pScoretodetail.get(key)[0].Core_MDF_Partnership_Score_Id__r.Core_MDF_Program_nm__c +''+pScoretodetail.get(key)[0].Core_MDF_Partnership_Score_Id__r.Core_MDF_Virtual_Corp_Account_Id__c + qtrforprevQtr;
                String keyForExtId=pScoretodetail.get(key)[0].Core_MDF_External_ID__c.substring(0,18)+pScoretodetail.get(key)[0].Core_MDF_Partnership_Score_Id__r.Core_MDF_Virtual_Corp_Account_Id__c + qtrforprevQtr;

                Core_MDF_Partnership_Score_Detail__c  pgd = new Core_MDF_Partnership_Score_Detail__c();
                List<Core_MDF_Partnership_Score__c> pscoreList = prgmAccQuarterYearToPScoreMap.get(keyForPS);
                if(pscoreList != null && !pscoreList.isEmpty()){
                    pgd.Core_MDF_Partnership_Score_Id__c = pscoreList[0].id;
                    pgd.Core_MDF_Region_Cd__c = pScoretodetail.get(key)[0].Core_MDF_Region_Cd__c;
                    pgd.Core_MDF_Budget_Type_nm__c = pScoretodetail.get(key)[0].Core_MDF_Budget_Type_Nm__c;
                    pgd.Core_MDF_Node_Account_Id__c = pScoretodetail.get(key)[0].Core_MDF_Node_Account_Id__c;
                    if(!psdKeyWithCurrentQuarter.contains(key)){
                        pgd.Core_MDF_Carry_Over_Amt__c  = pScoretodetail.get(key)[0].Core_MDF_Balance_Amount_Amt__c;
                        pgd.Core_MDF_Partnership_Score_Detail_Id__c = pScoretodetail.get(key)[0].Id;
                    }
                    pgd.Core_MDF_External_Id__c = keyForExtId + (String.isNotBlank(pgd.Core_MDF_Node_Account_Id__c) ? pgd.Core_MDF_Node_Account_Id__c + '' : '') + pgd.Core_MDF_Budget_Type_nm__c + pgd.Core_MDF_Region_Cd__c;
                    pgdRecToBeInserted.add(pgd);
                }
            }
        }

        if(!pgdRecToBeInserted.isEmpty()){
            Schema.SObjectField externalID = Core_MDF_Partnership_Score_Detail__c.Core_MDF_External_Id__c;
            Database.UpsertResult [] saveResult = Database.upsert(pgdRecToBeInserted, externalID, false);
        }
        
        }
        catch(exception ex){
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
    }
}