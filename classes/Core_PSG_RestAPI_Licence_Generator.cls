@RestResource(urlMapping='/freelicence')
global class Core_PSG_RestAPI_Licence_Generator {

    @HttpGet
    global static String doGet() {
        RestContext.response.addHeader('Content-Type', 'text/plain');
        String name = RestContext.request.params.get('name');
        return 'Hello '+name;
    }
}