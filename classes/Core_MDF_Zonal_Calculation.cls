public class Core_MDF_Zonal_Calculation {
    
    public static List<Core_MDF_Partnership_Score__c> get4Quarters(Id accountId,String programName,String reopenedQuarter) {
        // Expected format: 'Q2 2025'
        
        Integer quarterNum = Integer.valueOf(reopenedQuarter.substring(1, 2));
        Integer yearNum    = Integer.valueOf(reopenedQuarter.substring(3).trim());
        
        List<String> quartersToQuery = new List<String>();
        
        // Include current quarter
        quartersToQuery.add('Q' + quarterNum + ' ' + yearNum);
        
        // Add previous 3 quarters
        for (Integer i = 0; i < 3; i++) {
            quarterNum--;
            if (quarterNum == 0) {
                quarterNum = 4;
                yearNum--;
            }
            quartersToQuery.add('Q' + quarterNum + ' ' + yearNum);
        }
        System.debug('Quarters'+quartersToQuery);        
        // Query records
        List<Core_MDF_Partnership_Score__c> records = [
            SELECT
            Id,
            Core_MDF_Account_Id__c,
            Core_MDF_Channel_Program_Display__c,
            Core_MDF_Quarter_Year_Nm__c,
            Core_MDF_Zone_nm__c,
            Core_MDF_PartnershipScore_Nbr__c,
            Core_MDF_AggregateClaimScore_Nbr__c
            FROM Core_MDF_Partnership_Score__c
            WHERE Core_MDF_Account_Id__c = :accountId
            AND Core_MDF_Channel_Program_Display__c = :programName
            AND Core_MDF_Quarter_Year_Nm__c IN :quartersToQuery AND Core_MDF_PartnershipScore_Nbr__c >=0 AND Core_MDF_AggregateClaimScore_Nbr__c >=0 LIMIT 4
        ];
        
        // Sort: Latest Quarter → Oldest Quarter'
        if(records!=null){
        System.debug('records2..'+records);
        records.sort(new QuarterComparator());
        System.debug('records1..'+records);
        Integer size = records.size();
        List<Decimal> multipliers = new List<Decimal>();
        String labelValue = System.Label.Core_MDF_IAH_Values;
        List<Decimal> baseMultipliers = new List<Decimal>();
        for (String val : labelValue.split(',')) {
            baseMultipliers.add(Decimal.valueOf(val.trim()));
        }
        if (size == 1) {
            multipliers.add(baseMultipliers[0]);
        } 
        else if (size == 2) {
            multipliers.addAll(new List<Decimal>{baseMultipliers[1], baseMultipliers[2]});
        } 
        else if (size == 3) {
            multipliers.addAll(new List<Decimal>{baseMultipliers[3], baseMultipliers[4],baseMultipliers[5]});
        } 
        else if (size == 4) {
            multipliers.addAll(new List<Decimal>{baseMultipliers[6], baseMultipliers[7], baseMultipliers[8],baseMultipliers[9]});
        }
        //Decimal[] weights = new Decimal[] { 0.10, 0.20, 0.30, 0.40 };
            
            Decimal totalWeightedScore = 0;
        //Integer max = Math.min(records.size(), weights.size());
        System.debug('recordSize,,'+records.size()+'..multipliers.size()..'+multipliers.size()+'...size..'+size);
        Decimal aggregateScore;
        for (Integer i = 0; i < size; i++) {
            Core_MDF_Partnership_Score__c rec = records[i];
            if (rec.Core_MDF_Quarter_Year_Nm__c == reopenedQuarter)
            {
                aggregateScore = rec.Core_MDF_AggregateClaimScore_Nbr__c;
                System.debug('aggregateScore...'+aggregateScore);
            }
            
            if (rec.Core_MDF_PartnershipScore_Nbr__c != null) {
                Decimal weightedValue =
                    rec.Core_MDF_PartnershipScore_Nbr__c * multipliers[i];
                
                totalWeightedScore += weightedValue; //totalWeightedScore - create a new formula field to store 4 quarter value for Q2 2025
                
                System.debug(
                    'Quarter=' + rec.Core_MDF_Quarter_Year_Nm__c +
                    ' | Score=' + rec.Core_MDF_PartnershipScore_Nbr__c +
                    ' | Weight=' + (multipliers[i] * 100) + '%' +
                    ' | WeightedValue=' + weightedValue+
                    ' | totalWeightedScore=' +totalWeightedScore
                );
            }
        }
        
        Decimal percentageChange;
        
        if (!records.isEmpty()
            && records[0].Core_MDF_PartnershipScore_Nbr__c != null) {
                
                Decimal latestScore = records[0].Core_MDF_PartnershipScore_Nbr__c;
                System.debug('latestScore = ' +latestScore); 
                System.debug('(totalWeightedScore  = ' + totalWeightedScore); 

                System.debug('(totalWeightedScore - latestScore)1 = ' + (totalWeightedScore - latestScore)); 
                System.debug('(totalWeightedScore - latestScore)2 = ' + ((totalWeightedScore - latestScore) / latestScore)); 
                System.debug('(totalWeightedScore - latestScore)3 = ' + ((totalWeightedScore - latestScore) / latestScore) * 100); 
                percentageChange =
                    ((totalWeightedScore - latestScore) / latestScore) * 100;
                
            } else {
                percentageChange = 0; // or null, depending on business rule
            }
        getZone(percentageChange,aggregateScore);
        System.debug('Percentage Change = ' + percentageChange);
        }
        
        return records;
    }
    
    public class QuarterComparator implements Comparator<Core_MDF_Partnership_Score__c> {
        public Integer compare(Core_MDF_Partnership_Score__c a, Core_MDF_Partnership_Score__c b) {
            return getQuarterIndex(b.Core_MDF_Quarter_Year_Nm__c) - getQuarterIndex(a.Core_MDF_Quarter_Year_Nm__c);
        }
        
        // Convert 'Q1 2024' → 20241 (sortable number)
        private Integer getQuarterIndex(String quarter) {
            Integer q = Integer.valueOf(quarter.substring(1, 2));
            Integer y = Integer.valueOf(quarter.substring(3).trim());
            return (y * 10) + q;
        }
    }

    public static String getZone(Decimal row, Decimal col) {

        for (Core_MDF_Custom_Label_Configration__mdt m :
            [SELECT Id,MasterLabel, DeveloperName,Core_MDF_Category_Txt__c, Core_MDF_Value_Txt__c,Core_MDF_Value2_Txt__c,Core_MDF_Value3_Txt__c,Core_MDF_Value4_Txt__c,Core_MDF_Value5_Txt__c FROM Core_MDF_Custom_Label_Configration__mdt where Core_MDF_Category_Txt__c='IAH']) {

            if (row >= Decimal.valueOf(m.Core_MDF_Value2_Txt__c) && row <= Decimal.valueOf(m.Core_MDF_Value3_Txt__c) &&
                col >= Decimal.valueOf(m.Core_MDF_Value4_Txt__c) && col <= Decimal.valueOf(m.Core_MDF_Value5_Txt__c)) {
                    System.debug('m.Core_MDF_Value_Txt__c_'+m.Core_MDF_Value_Txt__c);
                return m.Core_MDF_Value_Txt__c;
            }
        }
        return null;
    }
}