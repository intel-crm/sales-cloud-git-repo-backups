public with sharing class Vivek_testapex {
    public Vivek_testapex() {
    }

    @AuraEnabled
    public static wrapper getWrapper(){
        wrapper obj = new wrapper();
        try {           
            obj.msg = 'There is an exception';
            obj.flg = true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return obj;
    }

    public class wrapper{
        @AuraEnabled public String msg;
        @AuraEnabled public Boolean flg;
    }    
}