public class POC_PartnerSorting {

    public static void getPartners(){
        List<p> partners = new List<p>();
        Map<String, Decimal> rankByTier = new Map<String, Decimal>();
        for(PMP_CustomSort_Mapping__mdt so : [SELECT Value__c, Rank__c, Sort_Type__c FROM PMP_CustomSort_Mapping__mdt where Sort_Type__c = 'Partner Tier']){
            rankByTier.put(so.Value__c, so.Rank__c);
        }
        for(PMP_Company__c ptnr: [select Name,PMP_IPA_Badge_Tier_Txt__c from PMP_Company__c Order by PMP_IPA_Badge_Tier_Txt__c,Name ASC]){
            p partner = new p();
            partner.name = ptnr.Name;
            partner.tier = ptnr.PMP_IPA_Badge_Tier_Txt__c;
            partner.rank = ptnr.PMP_IPA_Badge_Tier_Txt__c != null ? (Integer)rankByTier.get(ptnr.PMP_IPA_Badge_Tier_Txt__c) : (Integer)rankByTier.get('Last');
            partners.add(partner);
        }
        List<p> sortedPartners = sortPartners(partners);
        for(p sp : sortedPartners){
            System.debug('Sorted- '+sp.rank+'_'+sp.tier);
        }
    }
	
    public static List<p> sortPartners(List<p> partners){
        Map<Integer, List<p>> partnersByRank = new Map<Integer, List<p>>();
        List<p> sortedPartners = new List<p>();
        for(p partner: partners){
            if(partnersByRank.containsKey(partner.rank)){
                partnersByRank.get(partner.rank).add(partner);
            }
            else{
                partnersByRank.put(partner.rank, new List<p>{partner});
            }
        }
        List<Integer> ranks = new List<Integer>();
        ranks.addAll(partnersByRank.keySet());
        ranks.sort();
        for(Integer rank : ranks){
            sortedPartners.addAll(partnersByRank.get(rank));
        }
        return sortedPartners;
    }
    
    public class p{
        public String name { get; set; }
        public String tier { get; set; }
        public Integer rank { get; set; }
    }
}