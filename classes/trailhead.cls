public class trailhead {
    public class wrapper{
        @AuraEnabled 
        public string Points;
        @AuraEnabled 
        public string Rank;
        @AuraEnabled 
        public string OldPoints;
        @AuraEnabled 
        public string OldRank;
        @AuraEnabled 
        public Id userId;
        @AuraEnabled
        public string Username;
        @AuraEnabled
        public Integer badges;
    }

    public void getusertrailpername(string username){
    	//string username = 'Vivek';
        //string daterange = System.now().format();
        string strquery1 = 'select id,OldValue,NewValue, ParentId,field,CreatedDate from Trailhead_User__History where field in(\'Total_Points__c\') order by CreatedDate desc limit 1';
        Trailhead_User__History hst1 = Database.query(strquery1);
        System.debug(hst1);
        
        string strquery2 = 'select id,OldValue,NewValue, ParentId,field,CreatedDate from Trailhead_User__History where field in(\'Rank__c\') order by CreatedDate desc limit 1';
        Trailhead_User__History hst2 = Database.query(strquery2);
        System.debug(hst2);
        
        
    } 
    
    @AuraEnabled
    public static List<wrapper> getusertraildate(integer duration){
        Date today = date.today();
        Date lookupDate = today.addDays(-duration);

        List<Trailhead_User__c> res = [select Id,User__r.Name,Total_Points__c, Rank__c,User__c from Trailhead_User__c order by User__r.Name];
        system.debug(lookupDate);
        Map<string,string> mapData = new Map<String,String>();
        
        Map<id,Map<String,String>> trailmap = new Map<id,Map<String,String>>();
        for(integer i=0;i<res.size();i++){
            mapData = new Map<String,String>();
            mapData.put('Points',string.valueOf(res[i].Total_Points__c));
            mapData.put('Rank',res[i].Rank__c);
            mapData.put('Username',res[i].User__r.Name);
            trailmap.put(res[i].User__c,mapData);
        }    
        System.debug('First Map-> '+trailmap);                
       
        List<Trailhead_User__History> hst1 =  new List<Trailhead_User__History>();        
        Map<string,string> mapRes = new Map<string,string>(); 
        Map<id,Map<String,String>> trailMapRes = new Map<id,Map<String,String>>();
        List<wrapper> lstWrapper = new List<Wrapper>();

        for(Id key:trailmap.keySet()){            
            string qry = 'select id,OldValue,NewValue, ParentId,field,CreatedDate,Parent.User__c from Trailhead_User__History where field <> \'created\' and field = \'Total_Points__c\' and Parent.User__c =\''+ key +'\' and CreatedDate<:lookupDate order by CreatedDate desc limit 1';
            System.debug('Query-> '+qry);
            hst1 = Database.query(qry);  
            mapRes = trailmap.get(key);
            if(hst1.size()>0){
                mapRes.put('OldPoints',string.valueOf(hst1[0].OldValue));
            }                      
            string qry1 = 'select id,OldValue,NewValue, ParentId,field,CreatedDate,Parent.User__c from Trailhead_User__History where field <> \'created\' and field = \'Rank__c\' and Parent.User__c =\''+ key +'\' and CreatedDate<:lookupDate order by CreatedDate desc limit 1';
            hst1 = Database.query(qry1);
            if(hst1.size()>0){
                mapRes.put('OldRank',string.valueOf(hst1[0].OldValue));
            }

            string qry2 = 'select trailheadapp__User__c,count(id) cnt from trailheadapp__User_Badge__c where trailheadapp__User__c =\''+ key +'\' and trailheadapp__Status__c = \'Completed\' group by trailheadapp__User__c';
            AggregateResult[] hst5 = Database.query(qry2);
            if(hst5.size()>0){
                mapRes.put('badges',string.valueOf(hst5[0].get('cnt')));
            }
            else {
                mapRes.put('badges',string.valueOf(0));
            }
            //System.debug('History Map->'+mapRes);
            trailMapRes.put(key,mapRes);
        }        

        System.debug('Second Map-> '+trailMapRes);

        for(Id key:trailMapRes.keySet()){
            wrapper obj = new wrapper();
            obj.userId = key;
            obj.Rank = trailMapRes.get(key).get('Rank');
            obj.Points = trailMapRes.get(key).get('Points');    
            obj.OldRank = trailMapRes.get(key).get('OldRank');
            obj.OldPoints = trailMapRes.get(key).get('OldPoints');
            obj.Username = trailMapRes.get(key).get('Username');
            obj.badges = Integer.valueOf(trailMapRes.get(key).get('badges'));
            lstWrapper.add(obj);
        }       

        System.debug('Final wrapper-> '+lstWrapper);

        return lstWrapper;
    }

    @AuraEnabled
    public static List<wrapper> getusertrail(){
    	List<Trailhead_User__c> res = [select Id,User__r.Name,Total_Points__c, Rank__c,User__c from Trailhead_User__c order by User__r.Name];
        system.debug(res[0]);
        Map<string,string> mapData = new Map<String,String>();
        
        Map<id,Map<String,String>> trailmap = new Map<id,Map<String,String>>();
        for(integer i=0;i<res.size();i++){
            mapData = new Map<String,String>();
            mapData.put('Points',string.valueOf(res[i].Total_Points__c));
            mapData.put('Rank',res[i].Rank__c);
            mapData.put('Username',res[i].User__r.Name);
            // mapData.put('OldRank',null);
            // mapData.put('OldPoints',null);
            trailmap.put(res[i].User__c,mapData);
        }    
        System.debug('First Map-> '+trailmap);                
       
        List<Trailhead_User__History> hst1 =  new List<Trailhead_User__History>();        
        Map<string,string> mapRes = new Map<string,string>(); 
        Map<id,Map<String,String>> trailMapRes = new Map<id,Map<String,String>>();
        List<wrapper> lstWrapper = new List<Wrapper>();

        for(Id key:trailmap.keySet()){            
            string qry = 'select id,OldValue,NewValue, ParentId,field,CreatedDate,Parent.User__c from Trailhead_User__History where field <> \'created\' and field = \'Total_Points__c\' and Parent.User__c =\''+ key +'\' order by CreatedDate desc limit 1';
            hst1 = Database.query(qry);  
            mapRes = trailmap.get(key);
            mapRes.put('OldPoints',string.valueOf(hst1[0].OldValue));          
            string qry1 = 'select id,OldValue,NewValue, ParentId,field,CreatedDate,Parent.User__c from Trailhead_User__History where field <> \'created\' and field = \'Rank__c\' and Parent.User__c =\''+ key +'\' order by CreatedDate desc limit 1';
         	hst1 = Database.query(qry1);
            mapRes.put('OldRank',string.valueOf(hst1[0].OldValue));
            //System.debug('History Map->'+mapRes);
            trailMapRes.put(key,mapRes);
        }

        //system.debug('PointsMap-> '+mappoints);
        //system.debug('RanksMap-> '+maprank);
        System.debug('Second Map-> '+trailMapRes);

        for(Id key:trailMapRes.keySet()){
            wrapper obj = new wrapper();
            obj.userId = key;
            obj.Rank = trailMapRes.get(key).get('Rank');
            obj.Points = trailMapRes.get(key).get('Points');    
            obj.OldRank = trailMapRes.get(key).get('OldRank');
            obj.OldPoints = trailMapRes.get(key).get('OldPoints');
            obj.Username = trailMapRes.get(key).get('Username');
            lstWrapper.add(obj);
        }       

        System.debug('Final wrapper-> '+lstWrapper);

        return lstWrapper;
        
    }
        
//     select id,trailheadapp__User__c, trailheadapp__Badge__c, trailheadapp__Due_Date__c, trailheadapp__Finished_Date__c,Name,trailheadapp__Status__c from trailheadapp__User_Badge__c 
// where trailheadapp__User__c = '0051J000004kRTZQA2'
// select id, trailheadapp__Total_Badges_Awarded__c, Name, trailheadapp__API_Name__c, trailheadapp__Description__c, trailheadapp__Icon__c, trailheadapp__URL__c, trailheadapp__Namespace__c from trailheadapp__Badge__c 
}


/* List<Trailhead_User__c> res = [select Id,User__r.Name,Total_Points__c, Rank__c,User__c from Trailhead_User__c order by User__r.Name];    
Map<string,string> mapData = new Map<String,String>();
Map<id,Map<String,String>> trailmap = new Map<id,Map<String,String>>();
for(integer i=0;i<res.size();i++){
            mapData = new Map<String,String>();
            mapData.put('Points',string.valueOf(res[i].Total_Points__c));
            mapData.put('Rank',res[i].Rank__c);
            mapData.put('Username',res[i].User__r.Name);
            trailmap.put(res[i].Id,mapData);
}
Map<Id,Trailhead_User__History> map1 = new Map<Id,Trailhead_User__History>([select NewValue,CreatedDate,ParentId,Parent.User__c from Trailhead_User__History where field <>'created' and field = 'Total_Points__c']);
List<Trailhead_User__History> lst = map1.values();
Map<Id,String> mp = new Map<Id,String>();
for(Id key:trailmap.keyset()){
    for(Integer i=0;i<lst.size();i++){
        mp.put(key,String.ValueOf(lst[i].get('NewValue')));
        if(key == lst[i].get('ParentId') && mp.get(key)>String.ValueOf(lst[i].get('NewValue'))){
            string mySobj = mp.Remove(key);
            mp.put(key,String.ValueOf(lst[i].get('NewValue')));
            //System.Debug(lst[i].get('ParentId'));
        }
    }
}
System.debug(mp); */