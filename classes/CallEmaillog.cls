public class CallEmaillog {
    public static void callGraphApi() {
        // Replace this with a valid access token from delegated flow
        String accessToken ='eyJ0eXAiOiJKV1QiLCJub25jZSI6IkxvRmFTaGNFYVZ5Y1g5OUVCY0h5clUwb1daZm9ZUmxkNzB6RmpEVjgwLVkiLCJhbGciOiJSUzI1NiIsIng1dCI6IkNOdjBPSTNSd3FsSEZFVm5hb01Bc2hDSDJYRSIsImtpZCI6IkNOdjBPSTNSd3FsSEZFVm5hb01Bc2hDSDJYRSJ9.eyJhdWQiOiJodHRwczovL2dyYXBoLm1pY3Jvc29mdC5jb20iLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC80NmM5OGQ4OC1lMzQ0LTRlZDQtODQ5Ni00ZWQ3NzEyZTI1NWQvIiwiaWF0IjoxNzQ2NTI1NzI1LCJuYmYiOjE3NDY1MjU3MjUsImV4cCI6MTc0NjUyOTg5OCwiYWNjdCI6MCwiYWNyIjoiMSIsImFjcnMiOlsidXJuOnVzZXI6cmVnaXN0ZXJzZWN1cml0eWluZm8iLCJjMiJdLCJhaW8iOiJBWFFBaS84WkFBQUFoNjlPcE9HRGhaUVpBaHRvMy9FRXdUYWk4NW1CWGFZZElRRU53TGdBYzZpSVczVVBPVzFkMWc5aTkyd0U2UE1JRGVUL2dkZ3h3OFJFNXZtVjYwY1crbm41Qi80SXkvNjVYVTlTY2Zya296TkczQVZkY3hYVHlrVk5ETkwzSk9aaGE4MlZzdUtpVFNPa3c5MkJVUmpYL1E9PSIsImFtciI6WyJwd2QiXSwiYXBwX2Rpc3BsYXluYW1lIjoiUmVhZCBlbWFpbCIsImFwcGlkIjoiZTIzYTY2OTAtZjhjMi00MzFjLTg0ZGUtMjljM2Y4YjY4YWRkIiwiYXBwaWRhY3IiOiIxIiwiZmFtaWx5X25hbWUiOiJLYXVyIiwiZ2l2ZW5fbmFtZSI6Ik5hdm5lZXQiLCJpZHR5cCI6InVzZXIiLCJpcGFkZHIiOiIxOTIuNTUuNzkuMTgzIiwibmFtZSI6IkthdXIsIE5hdm5lZXQiLCJvaWQiOiI5YTJlYmEyMS0wNWQyLTRmMmMtYjk2My00ZjgzYzRjOGI2MzUiLCJvbnByZW1fc2lkIjoiUy0xLTUtMjEtMTAwNDMzNjM0OC0xMzgzMzg0ODk4LTE0MTcwMDEzMzMtODE5OTY2IiwicGxhdGYiOiIzIiwicHVpZCI6IjEwMDNCRkZEOUQ3Rjc2NTYiLCJyaCI6IjEuQVEwQWlJM0pSa1RqMUU2RWxrN1hjUzRsWFFNQUFBQUFBQUFBd0FBQUFBQUFBQUFOQUNZTkFBLiIsInNjcCI6IlVzZXIuUmVhZCBwcm9maWxlIG9wZW5pZCBlbWFpbCIsInNpZCI6IjAwNGQzZDg5LWFjYjktZjYwZi1mNjczLWZjMGU5NjQ3MDE1ZSIsInNpZ25pbl9zdGF0ZSI6WyJpbmtub3dubnR3ayIsImttc2kiXSwic3ViIjoiekIzVlJzaWExWXN6aUVmWkdOenE2ZS1QTGhhSmlsYXVBY3JOdXNGTzQ2QSIsInRlbmFudF9yZWdpb25fc2NvcGUiOiJOQSIsInRpZCI6IjQ2Yzk4ZDg4LWUzNDQtNGVkNC04NDk2LTRlZDc3MTJlMjU1ZCIsInVuaXF1ZV9uYW1lIjoibmF2bmVldC5rYXVyQGludGVsLmNvbSIsInVwbiI6Im5hdm5lZXQua2F1ckBpbnRlbC5jb20iLCJ1dGkiOiJudkxsaWtadGFrNlNsbm5zOW9OUEFBIiwidmVyIjoiMS4wIiwid2lkcyI6WyJiNzlmYmY0ZC0zZWY5LTQ2ODktODE0My03NmIxOTRlODU1MDkiXSwieG1zX2lkcmVsIjoiNiAxIiwieG1zX3N0Ijp7InN1YiI6Il9FZmVxV3UwSVh6cTFyM3FZLU82SjlTb2hZckMyOHNfR3ltN0llSGg5S0EifSwieG1zX3RjZHQiOjE0MzgwMzY3NTF9.A3qing4C4_rZ7qqagc7_7JF2SImqzQeVgdaPCmIdriwjctexNElgZcZ_e8zhJ5odejXCU7084Djg-zjsRKch4Ll6TtOjtuKNdHoANXtsWXEho1L_AUcbV528FXywoguom_vYTYZCmq9dsP5xu4_A4J_Bbrm9j0LuDa4O-aRayKs1L3VcxxTBnEv7oqkBFaOsedHfdVLmXCyGD9nubZjw3pjP7lq-nRJGCBIDS3i4cxY2fdov8DJ83RbStgoHzzapp_GnQXfsjSaMsVcLRaYleDOIcQ4pH7Zwc0Jyo-c3lN2zNkLTxzmnUuhIY5pE3rfdXcXNm9izGVru_7lojrPaEA';
		HttpRequest req = new HttpRequest();
        req.setEndpoint('https://graph.microsoft.com/v1.0/me');
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Accept', 'application/json');

        Http http = new Http();
        HTTPResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            System.debug('Response: ' + res.getBody());
        } else {
            System.debug('Error ' + res.getStatusCode() + ': ' + res.getBody());
        }
    
}
   
}