@RestResource(urlMapping='/skrestcustom')
global class SKRestCustom {
    
    @HttpGet
    global static String getCases(){
        List<Case> caseList = null;
        JSONGenerator gen = JSON.createGenerator(true);
        try{
            caseList = [SELECT Id,CaseNumber,Status,Subject,LastModifiedDate
                        FROM case order by LastModifiedDate Desc LIMIT 200];
            
            
            for(Case caseRec: caseList)
            {
                gen.writeObject(caseRec);   
            }
            System.debug(' In FINAL Method '+JSON.serialize(caseList));
            System.debug(' In FINAL Method '+gen.getAsString());
        }
        catch(Exception ex){
            system.debug('Exception Occured '+ ex);
        }finally{
            
        }
        return gen.getAsString();//JSON.serialize(caseList);
    }
    
    
}