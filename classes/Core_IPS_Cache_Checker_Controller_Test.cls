@isTest
public class Core_IPS_Cache_Checker_Controller_Test {
    public static testmethod void plateformCacheCheck(){
        Core_IPS_Cache_Checker_Controller cont=new Core_IPS_Cache_Checker_Controller();
        Core_IPS_Cache_Checker_Controller.createDeflected();
        Core_IPS_Cache_Checker_Controller.putCache();
        Core_IPS_Cache_Checker_Controller.getCache('test');
    }
}