@RestResource(urlMapping='/iupgm/test/*')
global with sharing class Core_MDF_TestAPI {

    @HttpGet
    global static String testAPI() {

        return 'API Working';
    }
}